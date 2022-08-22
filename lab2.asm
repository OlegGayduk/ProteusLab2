#include <P16F877A.INC>	

__CONFIG _WDT_OFF&_HS_OSC&_PWRTE_ON&_LVP_OFF
 COUNT1  EQU 0x21
 OUT     EQU 0X22
 Reg_1   EQU 0X23
 Reg_2   EQU 0X24
 OUT_2   EQU 0x25
 COUNT2  EQU 0x26
 COUNT_T EQU 0x27
 Reg_3   EQU 0X28
ORG 0x0000
 GOTO INIT

ORG 0x0004
GOTO INTERRUPT_TIMER
ORG 0x0005

INIT
 BCF STATUS,RP0
 BCF STATUS,RP1        ;инит
 BCF STATUS,IRP        ;инит
 MOVLW 0x9F
 MOVWF FSR             ;Адрес регистра ADCON1(тип PORTA)
 MOVLW 0x06            ;PORTA Digital
 MOVWF INDF           
 
 MOVLW 0X00
 MOVWF INTCON          ;инит
 CLRF PORTA
 CLRF PORTB
 CLRF PORTC
 CLRF PORTD
 CLRF PORTE
 MOVLW 0X85
 MOVWF FSR             ;указатель
 MOVLW 0X00 
 MOVWF INDF             ;TRISA выход
 MOVLW 0X86
 MOVWF FSR
 MOVLW 0X10
 MOVWF INDF          ;TRISB выход,RB4 вход
 MOVLW 0x87
 MOVWF FSR           ;TRISC
 MOVLW 0x00
 MOVWF INDF          ;TRISC выход
 MOVLW 0x88
 MOVWF FSR           ;TRISD
 MOVLW 0X00
 MOVWF INDF          ;TRISD выход
 MOVLW 0x89
 MOVWF FSR            ;TRISE
 MOVLW 0x00
 MOVWF INDF           ;TRISE выход

INIT2
 MOVLW 0X00
 MOVWF COUNT1        ;инит счетчика 1
 MOVLW 0X00
 MOVWF COUNT2        ;инит счетчика 2
 MOVLW 0X01
 MOVWF OUT
 MOVLW B'11111110'
 MOVWF OUT_2

MAIN                 ;зажигаеи светодиоды слева направо
 BTFSC COUNT1,3     ;если 4 бит равен 1(1000) то переход
 GOTO MAIN2         ;на гашение
 BTFSC PORTB,4      ; проверяем нажатие RB4,уход в 0
 GOTO MAIN
 CALL DELAY_RB4     ;задержка 250 мс,дребезг контакта
 CALL INIT_TIMER
 IORWF OUT          ;побитное или с W
 MOVF OUT,0         ;переслать в W
 MOVWF PORTD
 INCF COUNT1        ;инкремент счетчика нажатий RB4
 RLF OUT            ;циклический сдвиг влево
 MOVLW 0X01
LOOP2
 BTFSS PORTB,4     ;проверка отжатия кнопки RB4
 GOTO LOOP2
 GOTO MAIN

MAIN2               ;гасим светодиоды слева направо
 BTFSC COUNT2,3
 GOTO INIT2
 BTFSC PORTB,4      ;проверка нажатия кнопки
 GOTO MAIN2
 CALL DELAY_RB4     ;задержка 20 мс,дребезг
 CALL INIT_TIMER
 MOVF OUT_2,0 
 ANDWF PORTD         ;побитовое И W и PORTB
 INCF COUNT2
 RLF OUT_2
LOOP3
 BTFSS PORTB,4
 GOTO LOOP3
 GOTO MAIN2

INIT_TIMER 
  MOVLW 0X81  ;регистр OPTION
  MOVWF FSR 
  MOVLW 0X87
  MOVWF INDF 
  MOVLW .2
  MOVWF TMR0
  MOVLW 0xA0
  MOVWF INTCON
  MOVLW 0x00
  MOVWF COUNT_T
  MOVLW  0X01   ;возврат значение W
  RETURN
  
INTERRUPT_TIMER
  BCF INTCON,T0IF
  MOVLW 0xA0
  MOVWF INTCON
  MOVLW .2
  MOVWF TMR0
  INCF COUNT_T
  BTFSC COUNT_T,7 ;проверка заполнения доп счетчика
  CALL Run_Fire
  BTFSS PORTB,4 ;проверка нажата ли RB4
  RETURN
  MOVLW 0x00
  MOVWF INTCON   ;запрещаем прерывания
  RETURN

Run_Fire
  MOVLW 0x00
  MOVWF INTCON      ;глобальное запрещение прерывания
  MOVLW 0X00

  MOVWF COUNT1
  MOVLW 0X01
  MOVWF  OUT
  MOVLW 0X00
  MOVWF COUNT2
  MOVLW B'11111110'
  MOVWF OUT_2
LOOP4             ;зажигаем светодиоды
  MOVF OUT,0          ;В W
  IORWF PORTD
  CALL  DELAY_FIRE
  BTFSC PORTB,4   ;RB4 если 1 то стоп
  GOTO INIT2
  INCF COUNT1
  RLF OUT
  BTFSC COUNT1,3
  GOTO LOOP5
  GOTO LOOP4
LOOP5             ;гасим светодиоды
  MOVF OUT_2,0
  ANDWF PORTD
  CALL  DELAY_FIRE
  BTFSC PORTB,4   ;RB4 если 1 то стоп
  GOTO INIT2
  INCF COUNT2
  RLF OUT_2
  BTFSC COUNT2,3
  GOTO Run_Fire
  GOTO LOOP5
  
DELAY_RB4          ;подпрограмма задежвки на 250 мс,RA0           
  MOVLW       .89
  MOVWF       Reg_1
  MOVLW       .88
  MOVWF       Reg_2
  MOVLW       .7
  MOVWF       Reg_3
  DECFSZ      Reg_1,F
  GOTO          $-1
  DECFSZ      Reg_2,F
  GOTO          $-3
  DECFSZ      Reg_3,F
  GOTO          $-5
  NOP
  NOP
  MOVLW       0X01  ;возврат значение W
  RETURN

DELAY_FIRE           ;задержка 100мс
  MOVLW       .85
  MOVWF       Reg_1
  MOVLW       .138
  MOVWF       Reg_2
  MOVLW       .3
  MOVWF       Reg_3
  DECFSZ      Reg_1,F
  GOTO        $-1
  DECFSZ      Reg_2,F
  GOTO        $-3
  DECFSZ      Reg_3,F
  GOTO        $-5
  MOVLW 0X01
  RETURN

END
