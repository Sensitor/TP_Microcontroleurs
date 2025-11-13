PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	
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
    
    
    goto loop

loop:
    ; Boucle infinie
    goto loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end


