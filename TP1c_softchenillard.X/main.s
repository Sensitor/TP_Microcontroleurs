PROCESSOR 18F25K40
#include <xc.inc>

; ================================================================
; Config
; ================================================================
    config FEXTOSC = OFF
    config RSTOSC  = HFINTOSC_64MHZ
    config WDTE    = OFF


; ================================================================
; Définition des variables 
; ================================================================
Comp_L   equ 0x30     ; Compteur bas
Comp_H  equ 0x31     ; Compteur haut
Ledmove   equ 0x32     ; Motif chenillard


PSECT code, abs


; ================================================================
; Vecteurs
; ================================================================
org 0x000
    goto init_system

org 0x008
    goto High_ISR

org 0x018
    goto High_ISR


; ================================================================
; Initialisation du microcontrôleur
; ================================================================
org 0x100

init_system:

    ; Mettre RA6 / RA7 en numérique et entrée
    BANKSEL ANSELA
    bcf ANSELA,6
    bcf ANSELA,7

    BANKSEL TRISA
    bsf TRISA,6         ; Bouton B1
    bsf TRISA,7         ; Bounton B0

    ; PORTC en sortie 
    BANKSEL TRISC
    clrf TRISC

    ; Init des compteurs
    clrf Comp_L
    clrf Comp_H

    ; Motif initial : LED0 allumée
    movlw 0x01
    movwf Ledmove

    goto idle_check



; ========================================
; Attente qu?un bouton soit pressé
idle_check:

    ; Boutons actifs à l'état bas
    btfss PORTA,6       ; Si RA6 = 1 -> non appuyé -> skip
        goto counter_loop

    btfss PORTA,7
        goto counter_loop

    goto idle_check



; ================================================================
; Incrémentation du compteur & tempo

counter_loop:

    addwf 1
    bc nextByte         ; Overflow ? passer au MSB (incrémente)

    ; tempo
    nop
    nop
    nop

    goto idle_check


nextByte:
    movf Comp_H,W ; 
    addlw 1     ; On inc W
    movwf Comp_H ; 

    bc rotate_leds      ; MSB overflow ? on avance le chenillard

    goto idle_check ; sinon back to idle



; ================================================================
; Routine du chenillard
rotate_leds:

    movf Ledmove,W ; on charge le motif actuel

    ; BP1 = RA6 ? rotation droite
    btfss PORTA,6
        rrncf Ledmove

    ; BP0 = RA7 ? rotation gauche
    btfss PORTA,7
        rlncf Ledmove

    movff Ledmove, LATC ; on affiche

    goto idle_check



; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie

end
