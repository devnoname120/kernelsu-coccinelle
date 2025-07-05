// Usually in `fs/devpts/inode.c`

@devpts_get_priv@
identifier dentry;
@@

+#ifdef CONFIG_KSU
+extern int ksu_handle_devpts(struct inode*);
+#endif
devpts_get_priv(struct dentry *dentry) {
+#ifdef CONFIG_KSU
+ksu_handle_devpts(dentry->d_inode);
+#endif
...
}

// Usually in `fs/exec.c`

@@
attribute name __read_mostly;
identifier fd, filename, argv, envp, flags;
@@

+#ifdef CONFIG_KSU
+extern bool ksu_execveat_hook __read_mostly;
+extern int ksu_handle_execveat(int *fd, struct filename **filename_ptr, void *argv, void *envp, int *flags);
+extern int ksu_handle_execveat_sucompat(int *fd, struct filename **filename_ptr, void *argv, void *envp, int *flags);
+#endif
do_execveat_common(int fd, struct filename *filename, struct user_arg_ptr argv, struct user_arg_ptr envp, int flags) {
+#ifdef CONFIG_KSU
+if (unlikely(ksu_execveat_hook))
+  ksu_handle_execveat(&fd, &filename, &argv, &envp, &flags);
+else
+  ksu_handle_execveat_sucompat(&fd, &filename, &argv, &envp, &flags);
+#endif
...
}

// Usually in `fs/open.c`

@do_faccesssat@
attribute name __user;
identifier dfd, filename, mode;
@@

+#ifdef CONFIG_KSU
+extern int ksu_handle_faccessat(int *dfd, const char __user **filename_user, int *mode, int *flags);
+#endif
do_faccessat(int dfd, const char __user *filename, int mode) {
+#ifdef CONFIG_KSU
+ksu_handle_faccessat(&dfd, &filename, &mode, NULL);
+#endif
...
}

@syscall_faccesssat depends on never do_faccesssat@
attribute name __user;
identifier dfd, filename, mode;
@@

+#ifdef CONFIG_KSU
+extern int ksu_handle_faccessat(int *dfd, const char __user **filename_user, int *mode, int *flags);
+#endif
// SYSCALL_DEFINE3(faccessat, ...) {}
faccessat(int dfd, const char __user * filename, int mode) {
+#ifdef CONFIG_KSU
+ksu_handle_faccessat(&dfd, &filename, &mode, NULL);
+#endif
...
}

// Usually in `drivers/input/input.c`

@input_handle_event@
attribute name __read_mostly;
identifier disposition, dev, type, code, value;
@@
+#if defined(CONFIG_KPROBES) || defined(CONFIG_HAVE_KPROBES)
+#error KernelSU: You're using manual hooks but you also enabled CONFIG_KPROBES or CONFIG_HAVE_KPROBES. Remove CONFIG_KPROBES=y and CONFIG_HAVE_KPROBES=y from your defconfig, noob.
+#endif
+
+#ifdef CONFIG_KSU
+extern bool ksu_input_hook __read_mostly;
+extern int ksu_handle_input_handle_event(unsigned int *type, unsigned int *code, int *value);
+#endif
input_handle_event(struct input_dev *dev, unsigned int type, unsigned int code, int value) {
...
int disposition = input_get_disposition(dev, type, code, &value);
+#ifdef CONFIG_KSU
+if (unlikely(ksu_input_hook))
+  ksu_handle_input_handle_event(&type, &code, &value);
+#endif
...
}
@has_can_umount@
identifier path, flags;
@@
can_umount(const struct path *path, int flags) { ... }

// For `fs/namespace.c`
@path_umount depends on file in "namespace.c" && never has_can_umount@
@@
+static int can_umount(const struct path *path, int flags)
+{
+struct mount *mnt = real_mount(path->mnt);
+
+if (flags & ~(MNT_FORCE | MNT_DETACH | MNT_EXPIRE | UMOUNT_NOFOLLOW))
+  return -EINVAL;
+if (!may_mount())
+  return -EPERM;
+if (path->dentry != path->mnt->mnt_root)
+  return -EINVAL;
+if (!check_mnt(mnt))
+  return -EINVAL;
+if (mnt->mnt.mnt_flags & MNT_LOCKED) /* Check optimistically */
+  return -EINVAL;
+if (flags & MNT_FORCE && !capable(CAP_SYS_ADMIN))
+  return -EPERM;
+return 0;
+}
+
+int path_umount(struct path *path, int flags)
+{
+struct mount *mnt = real_mount(path->mnt);
+int ret;
+
+ret = can_umount(path, flags);
+if (!ret)
+  ret = do_umount(mnt, flags);
+
+/* we mustn't call path_put() as that would clear mnt_expiry_mark */
+dput(path->dentry);
+mntput_no_expire(mnt);
+return ret;
+}
mnt_alloc_id(...) { ... }

@path_umount_h depends on file in "internal.h"@
@@
__mnt_drop_write_file(...);
+int path_umount(struct path *path, int flags);

// Usually in `fs/read_write.c`

@vfs_read@
attribute name __read_mostly, __user;
identifier file, buf, count, pos;
@@

+#ifdef CONFIG_KSU
+extern bool ksu_vfs_read_hook __read_mostly;
+extern int ksu_handle_vfs_read(struct file **file_ptr, char __user **buf_ptr, size_t *count_ptr, loff_t **pos);
+#endif
vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) {
+#ifdef CONFIG_KSU
+if (unlikely(ksu_vfs_read_hook))
+  ksu_handle_vfs_read(&file, &buf, &count, &pos);
+#endif
...
}

// Usually in `fs/stat.c`

@vfs_statx@
attribute name __user;
identifier dfd, filename, flags;
@@

+#ifdef CONFIG_KSU
+extern int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
+#endif
vfs_statx(int dfd, const char __user *filename, int flags, ...) {
+#ifdef CONFIG_KSU
+ksu_handle_stat(&dfd, &filename, &flags);
+#endif
...
}

@vfs_fstatat depends on never vfs_statx@
attribute name __user;
identifier dfd, filename, stat, flag;
@@
+#ifdef CONFIG_KSU
+extern int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
+#endif
vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat, int flag) {
+#ifdef CONFIG_KSU
+ksu_handle_stat(&dfd, &filename, &flag);
+#endif
...
}
