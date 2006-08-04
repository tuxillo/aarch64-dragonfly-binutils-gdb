// gold.h -- general definitions for gold   -*- C++ -*-

#ifndef GOLD_GOLD_H

#include "config.h"
#include "ansidecl.h"

#ifdef ENABLE_NLS
# include <libintl.h>
# define _(String) gettext (String)
# ifdef gettext_noop
#  define N_(String) gettext_noop (String)
# else
#  define N_(String) (String)
# endif
#else
# define gettext(Msgid) (Msgid)
# define dgettext(Domainname, Msgid) (Msgid)
# define dcgettext(Domainname, Msgid, Category) (Msgid)
# define textdomain(Domainname) while (0) /* nothing */
# define bindtextdomain(Domainname, Dirname) while (0) /* nothing */
# define _(String) (String)
# define N_(String) (String)
#endif

// Figure out how to get a hash set and a hash map.  The fallback is
// to just use set and map.

#include <tr1/unordered_set>
#include <tr1/unordered_map>

// We need a template typedef here.

#define Unordered_set std::tr1::unordered_set
#define Unordered_map std::tr1::unordered_map

namespace gold
{

// The name of the program as used in error messages.
extern const char* program_name;

// This function is called to exit the program.  Status is true to
// exit success (0) and false to exit failure (1).
extern void
gold_exit(bool status) ATTRIBUTE_NORETURN;

// This function is called to emit an unexpected error message and a
// newline, and then exit with failure.  If PERRNO is true, it reports
// the error in errno.
extern void
gold_fatal(const char* msg, bool perrno) ATTRIBUTE_NORETURN;

// This is function is called in some cases if we run out of memory.
extern void
gold_nomem() ATTRIBUTE_NORETURN;

// This function is called in cases which can not arise if the code is
// written correctly.
extern void
gold_unreachable() ATTRIBUTE_NORETURN;

} // End namespace gold.

#endif // !defined(GOLD_GOLD_H)
