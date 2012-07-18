/*
 * Copyright © 2011,2012  Google, Inc.
 *
 *  This is part of HarfBuzz, a text shaping library.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and its documentation for any purpose, provided that the
 * above copyright notice and the following two paragraphs appear in
 * all copies of this software.
 *
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
 * IF THE COPYRIGHT HOLDER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 * THE COPYRIGHT HOLDER SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING,
 * BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE COPYRIGHT HOLDER HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * Google Author(s): Behdad Esfahbod
 */

#ifndef HB_OT_SHAPE_COMPLEX_INDIC_MACHINE_HH
#define HB_OT_SHAPE_COMPLEX_INDIC_MACHINE_HH

#include "hb-private.hh"

%%{
  machine indic_syllable_machine;
  alphtype unsigned char;
  write data;
}%%

%%{

# Same order as enum indic_category_t.  Not sure how to avoid duplication.
X    = 0;
C    = 1;
V    = 2;
N    = 3;
H    = 4;
ZWNJ = 5;
ZWJ  = 6;
M    = 7;
SM   = 8;
VD   = 9;
A    = 10;
NBSP = 11;
DOTTEDCIRCLE = 12;
RS   = 13;
Coeng = 14;
Repha = 15;
Ra    = 16;

c = (C | Ra);			# is_consonant
n = ((ZWNJ?.RS)? (N.N?)?);	# is_consonant_modifier
z = ZWJ|ZWNJ;			# is_joiner
h = H | Coeng;			# is_halant_or_coeng
reph = (Ra H | Repha);		# possible reph

cn = c.n?;
matra_group = z*.M.N?.H?;
syllable_tail = SM? (Coeng (cn|V))? (VD VD?)?;
place_holder = NBSP | DOTTEDCIRCLE;
halant_group = (h.z?|z.h);
halant_or_matra_group = (halant_group | matra_group*);


consonant_syllable =	Repha? (cn.halant_group)* cn A? halant_or_matra_group? syllable_tail;
vowel_syllable =	reph? V.n? (halant_group.cn | ZWJ.cn)* halant_or_matra_group? syllable_tail;
standalone_cluster =	reph? place_holder.n? (halant_group.cn)* halant_or_matra_group? syllable_tail;
other =			any;

main := |*
	consonant_syllable	=> { process_syllable (consonant_syllable); };
	vowel_syllable		=> { process_syllable (vowel_syllable); };
	standalone_cluster	=> { process_syllable (standalone_cluster); };
	other			=> { process_syllable (non_indic); };
*|;


}%%

#define process_syllable(func) \
  HB_STMT_START { \
    if (0) fprintf (stderr, "syllable %d..%d %s\n", last, p+1, #func); \
    for (unsigned int i = last; i < p+1; i++) \
      info[i].syllable() = syllable_serial; \
    PASTE (initial_reordering_, func) (map, buffer, mask_array, last, p+1); \
    last = p+1; \
    syllable_serial++; \
    if (unlikely (!syllable_serial)) syllable_serial++; \
  } HB_STMT_END

static void
find_syllables (const hb_ot_map_t *map, hb_buffer_t *buffer, hb_mask_t *mask_array)
{
  unsigned int p, pe, eof, ts, te, act;
  int cs;
  hb_glyph_info_t *info = buffer->info;
  %%{
    write init;
    getkey info[p].indic_category();
  }%%

  p = 0;
  pe = eof = buffer->len;

  unsigned int last = 0;
  uint8_t syllable_serial = 1;
  %%{
    write exec;
  }%%
}

#endif /* HB_OT_SHAPE_COMPLEX_INDIC_MACHINE_HH */
