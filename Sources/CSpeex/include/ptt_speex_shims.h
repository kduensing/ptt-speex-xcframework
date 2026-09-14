// Swift-visible shims for the vendored libspeex decoder (see SpeexDecoder.swift).
//
// speex.h defines speex_lib_get_mode() as a function-like macro (which Swift
// can't import) shadowing the real function, and getting a stable address of
// the extern-const mode globals from Swift is awkward. These shims hand back
// the actual global's address, which is stable for the program's lifetime -
// speex_decoder_init() retains the pointer, so it must not be transient.

#ifndef PTT_SPEEX_SHIMS_H
#define PTT_SPEEX_SHIMS_H

#include "speex/speex.h"

static inline const SpeexMode *ptt_speex_mode_wb(void) { return &speex_wb_mode; }
static inline const SpeexMode *ptt_speex_mode_nb(void) { return &speex_nb_mode; }

#endif /* PTT_SPEEX_SHIMS_H */
