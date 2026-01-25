#include <linux/init.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("JA");
MODULE_DESCRIPTION("skeleton");

static int ldd_init(void)
{
 printk("Hello From Kernel Module\n");
 return 0;
}

static void ldd_exit(void)
{
 printk("Good bye From Kernel Module\n");
}
module_init(ldd_init);
module_exit(ldd_exit);