/* config.h for vendored Speex in the PTT project.
 * Adapted from coredevices/PebbleOS's third_party/speex/config.h
 * (src/fw/services/voice/voice_speex.c is the reference for the encoder
 * parameters this build is meant to support: fixed-point, wideband, CBR).
 * Unlike PebbleOS, this build targets ESP32 Arduino, which has a full libc
 * (malloc/free/calloc, stdio), so the OVERRIDE_SPEEX_* custom-allocator
 * hooks PebbleOS needs for their embedded RTOS are omitted here - os_support.h's
 * default calloc/realloc/free-based implementation is used instead.
 */
#ifndef CONFIG_H
#define CONFIG_H

#define HAVE_STDINT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_MALLOC 1
#define HAVE_MEMCPY 1
#define HAVE_MEMMOVE 1
#define HAVE_MEMSET 1

#define EXPORT

/* Fixed-point build: ESP32-C3 (RISC-V) has no hardware FPU, so this isn't
 * just a size optimization - it's the only sane choice for performance. */
#define FIXED_POINT 1
#define DISABLE_FLOAT_API 1

/* CBR only, matching PebbleOS's proven working config. */
#define DISABLE_VBR 1

/* Wideband mode required - do not define DISABLE_WIDEBAND. */

#define HAVE_ALLOCA 1
#define HAVE_ALLOCA_H 1

#define SIZEOF_INT 4
#define SIZEOF_LONG 4
#define SIZEOF_SHORT 2

#define VERSION "1.2.1"

#define X_DISPLAY_MISSING 1

/* Force fixed-point code paths instead of pulling in libm. */
#undef HAVE_STDIO_H
#undef HAVE_STDLIB_H
#undef HAVE_SQRT
#undef HAVE_FLOOR
#undef HAVE_COS
#undef HAVE_SIN
#undef HAVE_EXP
#undef HAVE_LOG
#undef HAVE_POW
#undef HAVE_RINT
#undef HAVE_FABS

#endif /* CONFIG_H */
