
;  Copyright 2023, David S. Madole <david@madole.net>
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.


          ; Definition files

          #include include/bios.inc
          #include include/kernel.inc


          ; Unpublished kernel vector points

d_ideread:  equ   0447h
d_idewrite: equ   044ah


          ; Executable header block

            org   1ffah
            dw    begin
            dw    end-begin
            dw    begin
 
begin:      br    start

            db    7+80h
            db    29
            dw    2023
            dw    1

            db    'See github/dmadole/Elfos-sys for more information',0


start:      ghi   ra
            phi   rf
            glo   ra
            plo   rf

            ldi   0                     ; presume no drive
            phi   r8

            phi   ra                    ; presume no label
            plo   ra


skplead:    lda   rf                    ; skip any leading spaces
            lbz   gotargs
            sdi   ' '
            lbdf  skplead

            sdi   ' '-'/'
            lbz   dodrive

            ghi   rf                    ; set ra to start of label
            phi   ra
            glo   rf
            plo   ra
            dec   ra

            ldn   ra                    ; is label actually an option
            smi   '-'
            lbnz  skpname

            lda   rf                    ; if not -z then error
            smi   'z'
            lbnz  dousage

            str   ra                    ; make name empty string

            lda   rf                    ; must be followed by space
            sdi   ' '
            lbnf  dousage

            lbr   skpspac

skpname:    lda   rf                    ; skip over label
            lbz   dousage
            sdi   ' '
            lbnf  skpname

nulname:    ldi   0                     ; zero-terminate label
            dec   rf
            str   rf
            inc   rf

skpspac:    lda   rf                    ; skip intervening spaces
            lbz   dousage
            sdi   ' '
            lbdf  skpspac

            sdi   ' '-'/'               ; next must be a slash
            lbnz  dousage

dodrive:    lda   rf                    ; followed by another slash
            smi   '/'
            lbnz  dousage

            sep   scall                 ; then drive number
            dw    f_atoi
            lbdf  dousage

            ghi   rd
            lbnz  dousage

            glo   rd                    ; save drive number
            smi   32
            lbdf  dousage

            ori   0e0h
            phi   r8

skptail:    lda   rf                    ; absorb trailing spaces
            lbz   gotargs
            sdi   ' '
            lbdf  skptail



dousage:    sep   scall                 ; otherwise display usage message
            dw    o_inmsg
            db    'USAGE: label [[-z|label] //drive]',13,10,0
            sep   sret                  ; and return to os


gotargs:    ghi   r8
            lbz   listing

            ghi   ra
            lbnz  writeit
            glo   ra
            lbnz  writeit




            ldi   0                     ; sector zero for boot code
            plo   r7
            phi   r7
            plo   r8

            ldi   buffer.1              ; pointer to buffer
            phi   rf
            ldi   buffer.0
            plo   rf

            sep   scall                 ; read sector zero
            dw    d_ideread
            lbnf  gotboot

            sep   scall
            dw    chkdisk
            lbdf  return

            sep   scall
            dw    o_inmsg
            db    'ERROR: could not read boot sector.',13,10,0

            sep   sret


gotboot:    ldi   (buffer+138h).1       ; pointer to name
            phi   rf
            ldi   (buffer+138h).0
            plo   rf

            ldn   rf
            lbz   return


            sep   scall
            dw    o_msg

            sep   scall
            dw    o_inmsg
            db    13,10,0

return:     sep   sret


listing:    ldi   0e0h
            phi   r8

drvloop:    ldi   0
            plo   r8
            phi   r7
            plo   r7

            ldi   buffer.1              ; pointer to buffer
            phi   rf
            ldi   buffer.0
            plo   rf

            sep   scall                 ; read sector zero
            dw    d_ideread
            lbdf  skipdrv

            sep   scall
            dw    chkdisk
            lbdf  skipdrv

            ldi   (buffer+138h).1       ; pointer to name
            phi   rf
            ldi   (buffer+138h).0
            plo   rf

            ldn   rf
            lbz   skipdrv

            ldi   string.1
            phi   rf
            ldi   string.0
            plo   rf

            ldi   '/'
            str   rf
            inc   rf
            str   rf
            inc   rf

            ghi   r8
            ani   31
            plo   rd
            ldi   0
            phi   rd

            sep   scall
            dw    f_uintout

            ldi   ':'
            str   rf
            inc   rf
            ldi   ' '
            str   rf
            inc   rf
            ldi   0
            str   rf

            ldi   string.1
            phi   rf
            ldi   string.0
            plo   rf

            sep   scall
            dw    o_msg

            ldi   (buffer+138h).1       ; pointer to name
            phi   rf
            ldi   (buffer+138h).0
            plo   rf

            sep   scall
            dw    o_msg

            sep   scall
            dw    o_inmsg
            db    13,10,0

skipdrv:    ghi   r8
            adi   1
            phi   r8

            lbnz  drvloop

            sep   sret


string:     db    '//0  ',0





writeit:    ghi   ra
            phi   rf
            glo   ra
            plo   rf

            ldi   21
            plo   re

strlen:     dec   re
            glo   re
            lbz   toolong

            lda   rf
            lbnz  strlen


            ldi   0                     ; sector zero for boot code
            plo   r7
            phi   r7
            plo   r8

            ldi   buffer.1              ; pointer to buffer
            phi   rf
            ldi   buffer.0
            plo   rf

            sep   scall                 ; read sector zero
            dw    d_ideread
            lbnf  gotwrit

            sep   scall
            dw    o_inmsg
            db    'ERROR: could not read boot sector.',13,10,0

            sep   sret


toolong:    sep   scall
            dw    o_inmsg
            db    'ERROR: label is more than 19 characters.',13,10,0

            sep   sret


gotwrit:    sep   scall
            dw    chkdisk
            lbnf  proceed

            sep   scall
            dw    o_inmsg
            db    'ERROR: disk is not Elf/OS formatted.',13,10,0

            sep   sret




proceed:    ldi   (buffer+138h).1       ; pointer to name
            phi   rf
            ldi   (buffer+138h).0
            plo   rf

strcpy:     lda   ra
            str   rf
            inc   rf
            lbnz  strcpy


            ldi   buffer.1              ; reset pointer to beginning
            phi   rf
            ldi   buffer.0
            plo   rf

            sep   scall                 ; write back to disk
            dw    d_idewrite
            lbdf  writerr

            sep   sret



writerr:    sep   scall                 ; indicate error
            dw    o_inmsg
            db    'ERROR: could not write boot sector',13,10,0

            sep   sret                  ; return to OS



chkdisk:    ldi   (buffer+100h).1       ; point to volume info
            phi   rf
            ldi   (buffer+100h).0
            plo   rf

            lda   rf                    ; if non-zero then too big
            phi   rb
            lbnz  isempty

            lda   rf                    ; if 8 or higher then too big
            plo   rb
            smi   8
            lbdf  isempty

            inc   rf                    ; low two bytes can be anything
            inc   rf

            lda   rf                    ; filesystem type must be one
            sdi   1
            lbnz  isempty

            inc   rf                    ; skip master directory sector
            inc   rf

            inc   rf                    ; bytes not currently used
            inc   rf
            inc   rf

            lda   rf                    ; sectors per au must be eight
            sdi   8
            lbz   isvalid

isempty:    smi   0
            sep   sret

isvalid:    adi   0
            sep   sret



buffer:     ds    512

end:        end   begin

