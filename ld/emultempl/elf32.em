# This shell script emits a C file. -*- C -*-
# It does some substitutions.
cat >e${EMULATION_NAME}.c <<EOF
/* This file is is generated by a shell script.  DO NOT EDIT! */

/* 32 bit ELF emulation code for ${EMULATION_NAME}
   Copyright (C) 1991, 1993, 1994 Free Software Foundation, Inc.
   Written by Steve Chamberlain <sac@cygnus.com>
   ELF support by Ian Lance Taylor <ian@cygnus.com>

This file is part of GLD, the Gnu Linker.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

#define TARGET_IS_${EMULATION_NAME}

#include "bfd.h"
#include "sysdep.h"
#include "bfdlink.h"

#include "ld.h"
#include "config.h"
#include "ldmain.h"
#include "ldemul.h"
#include "ldfile.h"
#include "ldmisc.h"
#include "ldexp.h"
#include "ldlang.h"

static void gld${EMULATION_NAME}_before_parse PARAMS ((void));
static void gld${EMULATION_NAME}_before_allocation PARAMS ((void));
static void gld${EMULATION_NAME}_find_statement_assignment
  PARAMS ((lang_statement_union_type *));
static void gld${EMULATION_NAME}_find_exp_assignment PARAMS ((etree_type *));
static char *gld${EMULATION_NAME}_get_script PARAMS ((int *isfile));

static void
gld${EMULATION_NAME}_before_parse()
{
  ldfile_output_architecture = bfd_arch_${ARCH};
  config.dynamic_link = true;
}

/* This is called after the sections have been attached to output
   sections, but before any sizes or addresses have been set.  */

static void
gld${EMULATION_NAME}_before_allocation ()
{
  asection *sinterp;

  /* If we are going to make any variable assignments, we need to let
     the ELF backend know about them in case the variables are
     referred to by dynamic objects.  */
  lang_for_each_statement (gld${EMULATION_NAME}_find_statement_assignment);

  /* Let the ELF backend work out the sizes of any sections required
     by dynamic linking.  */
  if (! bfd_elf32_size_dynamic_sections (output_bfd, &link_info,
					 &sinterp))
    einfo ("%P%F: failed to set dynamic section sizes: %E\n");

  /* Let the user override the dynamic linker we are using.  */
  if (command_line.interpreter != NULL
      && sinterp != NULL)
    {
      sinterp->contents = (bfd_byte *) command_line.interpreter;
      sinterp->_raw_size = strlen (command_line.interpreter) + 1;
    }
}

/* This is called by the before_allocation routine via
   lang_for_each_statement.  It locates any assignment statements, and
   tells the ELF backend about them, in case they are assignments to
   symbols which are referred to by dynamic objects.  */

static void
gld${EMULATION_NAME}_find_statement_assignment (s)
     lang_statement_union_type *s;
{
  if (s->header.type == lang_assignment_statement_enum)
    gld${EMULATION_NAME}_find_exp_assignment (s->assignment_statement.exp);
}

/* Look through an expression for an assignment statement.  */

static void
gld${EMULATION_NAME}_find_exp_assignment (exp)
     etree_type *exp;
{
  switch (exp->type.node_class)
    {
    case etree_assign:
      if (strcmp (exp->assign.dst, ".") != 0)
	{
	  if (! bfd_elf32_record_link_assignment (output_bfd, &link_info,
						  exp->assign.dst))
	    einfo ("%P%F: failed to record assignment to %s: %E\n",
		   exp->assign.dst);
	}
      gld${EMULATION_NAME}_find_exp_assignment (exp->assign.src);
      break;

    case etree_binary:
      gld${EMULATION_NAME}_find_exp_assignment (exp->binary.lhs);
      gld${EMULATION_NAME}_find_exp_assignment (exp->binary.rhs);
      break;

    case etree_trinary:
      gld${EMULATION_NAME}_find_exp_assignment (exp->trinary.lhs);
      gld${EMULATION_NAME}_find_exp_assignment (exp->trinary.lhs);
      gld${EMULATION_NAME}_find_exp_assignment (exp->trinary.rhs);
      break;

    case etree_unary:
      gld${EMULATION_NAME}_find_exp_assignment (exp->unary.child);
      break;

    default:
      break;
    }
}

static char *
gld${EMULATION_NAME}_get_script(isfile)
     int *isfile;
EOF

if test -n "$COMPILE_IN"
then
# Scripts compiled in.

# sed commands to quote an ld script as a C string.
sc='s/["\\]/\\&/g
s/$/\\n\\/
1s/^/"/
$s/$/n"/
'

cat >>e${EMULATION_NAME}.c <<EOF
{			     
  *isfile = 0;

  if (link_info.relocateable == true && config.build_constructors == true)
    return `sed "$sc" ldscripts/${EMULATION_NAME}.xu`;
  else if (link_info.relocateable == true)
    return `sed "$sc" ldscripts/${EMULATION_NAME}.xr`;
  else if (!config.text_read_only)
    return `sed "$sc" ldscripts/${EMULATION_NAME}.xbn`;
  else if (!config.magic_demand_paged)
    return `sed "$sc" ldscripts/${EMULATION_NAME}.xn`;
  else
    return `sed "$sc" ldscripts/${EMULATION_NAME}.x`;
}
EOF

else
# Scripts read from the filesystem.

cat >>e${EMULATION_NAME}.c <<EOF
{			     
  *isfile = 1;

  if (link_info.relocateable == true && config.build_constructors == true)
    return "ldscripts/${EMULATION_NAME}.xu";
  else if (link_info.relocateable == true)
    return "ldscripts/${EMULATION_NAME}.xr";
  else if (!config.text_read_only)
    return "ldscripts/${EMULATION_NAME}.xbn";
  else if (!config.magic_demand_paged)
    return "ldscripts/${EMULATION_NAME}.xn";
  else
    return "ldscripts/${EMULATION_NAME}.x";
}
EOF

fi

cat >>e${EMULATION_NAME}.c <<EOF

struct ld_emulation_xfer_struct ld_${EMULATION_NAME}_emulation = 
{
  gld${EMULATION_NAME}_before_parse,
  syslib_default,
  hll_default,
  after_parse_default,
  after_allocation_default,
  set_output_arch_default,
  ldemul_default_target,
  gld${EMULATION_NAME}_before_allocation,
  gld${EMULATION_NAME}_get_script,
  "${EMULATION_NAME}",
  "${OUTPUT_FORMAT}"
};
EOF
