#define MZ_PRECISE_GC

#include "scheme.h"

#include "base.c"

static int run(Scheme_Env *e, int argc, char *argv[])
{
    Scheme_Object *curout = NULL, *v = NULL, *a[2] = {NULL, NULL};
    Scheme_Config *config = NULL;
    Scheme_Object *args[2] = {NULL, NULL};
    int i;
    mz_jmp_buf * volatile save = NULL, fresh;
   
    // we'll need to set Racket collect path
    Scheme_Object *coldir =
        scheme_make_path([[[[NSBundle mainBundle] bundlePath]
                            stringByAppendingString:@"/icollects"] UTF8String]);
    scheme_set_collects_path(coldir);
   
    scheme_init_collection_paths(e, scheme_null);

    MZ_GC_DECL_REG(8);
    MZ_GC_VAR_IN_REG(0, e);
    MZ_GC_VAR_IN_REG(1, curout);
    MZ_GC_VAR_IN_REG(2, save);
    MZ_GC_VAR_IN_REG(3, config);
    MZ_GC_VAR_IN_REG(4, v);
    MZ_GC_ARRAY_VAR_IN_REG(5, a, 2);

    MZ_GC_REG();

    // No need to load embedded modules
    //declare_modules(e);

    v = scheme_intern_symbol("racket");
    scheme_namespace_require(v);

    config = scheme_current_config();
    curout = scheme_get_param(config, MZCONFIG_OUTPUT_PORT);
    
    {
        /*
         * This just simulates:
         * #./racket test.rkt
         */
        Scheme_Object *a[1], *nsreq;
        char *name = "file";
        nsreq = scheme_builtin_value("namespace-require");
        a[0] = scheme_make_pair(scheme_intern_symbol(name),
                                scheme_make_pair(scheme_make_utf8_string([[[[NSBundle mainBundle] bundlePath]
                                                                             stringByAppendingString:@"/test.rkt"]
                                                                                 UTF8String]),
                                                 scheme_make_null()));
        scheme_apply(nsreq, 1, a);
    }

    for (i = 0; i < argc; i++) {
        save = scheme_current_thread->error_buf;
        scheme_current_thread->error_buf = &fresh;
        if (scheme_setjmp(scheme_error_buf)) {
            scheme_current_thread->error_buf = save;
            return -1; /* There was an error */
        } else {
            v = scheme_eval_string(argv[i], e);
            scheme_display(v, curout);
            v = scheme_make_char('\n');
            scheme_display(v, curout);
            /* read-eval-print loop, uses initial Scheme_Env: */
            a[0] = scheme_intern_symbol("racket/base");
            a[1] = scheme_intern_symbol("display");
            v = scheme_dynamic_require(2, a);
            args[0] = scheme_make_byte_string("Hello world!");
            scheme_apply(v, 1, args);
            scheme_flush_output(curout);
            scheme_current_thread->error_buf = save;
        }
    }

    MZ_GC_UNREG();

    return 0;
}

int racket_main(int argc, char *argv[])
{
    return scheme_main_setup(1, run, argc, argv);
}
