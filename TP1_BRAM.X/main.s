PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	

compteur_lsb equ 0X20 ; octet de poids faible
compteur_msb equ 0X21 ; octet de poids fort
    
PSECT   code, abs
   
; Vecteur de reset =============================================================
org     0x000
goto init 
   
   
; Entrees/Sorties
; LEDO : RCO 
; LED1 : RC1
; LED2 : RC2
; LED3 : RC3
; LED4 : RC4
; LED5 : RC5
; LED6 : RC6
; LED7 : RC7   
   
   
; Vecteur d'interruption haute priorite ========================================
org     0x008
goto High_ISR 

; Vecteur d'interruption basse priorite ========================================
org     0x018
goto Low_ISR 

; Programme principal ==========================================================
org 0x100   

init:
    ; Initialisation   
    
    ; Config sorties
    
    BANKSEL TRISC       ; banque de mémoire du registre TRISC
    clrf TRISC          ; On met RC0-RC7 en SORTIE
    
    BANKSEL ANSELC      ; banque de mémoire du registre ANSELC
    clrf ANSELC         ; On met RC0-RC7 en mode numérique
    
    ; Compteur LSB et MSB
    
    clrf compteur_lsb    ; compteur_lsb = 0x00 
    clrf compteur_msb   ; compteur_msb = 0x00 (MSB). Init à 0x0000.
    
    
    goto loop

loop:
    ; Boucle infinie
    
    incfsz compteur_lsb ; compteur_lsb = compteur_lsb + 1
			; si compteur_lsb revient à 0 on skip le display
    
    goto display   ; si lsb pas à 0 on display directement
    
    incf compteur_msb ; lsb à 0 donc on incrémente le msb
    
    
display:
    ; On cherche à afficher le msb
    
    BANKSEL LATC        ; On se met sur le registre LATC (sortie)
    movf compteur_msb, W ; WREG = compteur_msb
    movwf LATC           ; LATC = WREG. Ainsi on affiche la valeur du msb sur les leds 0-7
                         ; LD0 aura le bit 0 du msb et LD7 le bit 7 du msb

    ; Boucle inf
    goto loop           ; On réincrémente

    
; Pour que toutes les leds s'allument, il faut attendre un certain temps, on a donc un délai
; Ce délai est basé sur les cycles d'horloge    
    
    
; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end
