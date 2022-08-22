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
 BCF STATUS,RP1        ;����
 BCF STATUS,IRP        ;����
 MOVLW 0x9F
 MOVWF FSR             ;����� �������� ADCON1(��� PORTA)
 MOVLW 0x06            ;PORTA Digital
 MOVWF INDF           
 
 MOVLW 0X00
 MOVWF INTCON          ;����
 CLRF PORTA
 CLRF PORTB
 CLRF PORTC
 CLRF PORTD
 CLRF PORTE
 MOVLW 0X85
 MOVWF FSR             ;���������
 MOVLW 0X00 
 MOVWF INDF             ;TRISA �����
 MOVLW 0X86
 MOVWF FSR
 MOVLW 0X10
 MOVWF INDF          ;TRISB �����,RB4 ����
 MOVLW 0x87
 MOVWF FSR           ;TRISC
 MOVLW 0x00
 MOVWF INDF          ;TRISC �����
 MOVLW 0x88
 MOVWF FSR           ;TRISD
 MOVLW 0X00
 MOVWF INDF          ;TRISD �����
 MOVLW 0x89
 MOVWF FSR            ;TRISE
 MOVLW 0x00
 MOVWF INDF           ;TRISE �����

INIT2
 MOVLW 0X00
 MOVWF COUNT1        ;���� �������� 1
 MOVLW 0X00
 MOVWF COUNT2        ;���� �������� 2
 MOVLW 0X01
 MOVWF OUT
 MOVLW B'11111110'
 MOVWF OUT_2

MAIN                 ;�������� ���������� ����� �������
 BTFSC COUNT1,3     ;���� 4 ��� ����� 1(1000) �� �������
 GOTO MAIN2         ;�� �������
 BTFSC PORTB,4      ; ��������� ������� RB4,���� � 0
 GOTO MAIN
 CALL DELAY_RB4     ;�������� 250 ��,������� ��������
 CALL INIT_TIMER
 IORWF OUT          ;�������� ��� � W
 MOVF OUT,0         ;��������� � W
 MOVWF PORTD
 INCF COUNT1        ;��������� �������� ������� RB4
 RLF OUT            ;����������� ����� �����
 MOVLW 0X01
LOOP2
 BTFSS PORTB,4     ;�������� ������� ������ RB4
 GOTO LOOP2
 GOTO MAIN

MAIN2               ;����� ���������� ����� �������
 BTFSC COUNT2,3
 GOTO INIT2
 BTFSC PORTB,4      ;�������� ������� ������
 GOTO MAIN2
 CALL DELAY_RB4     ;�������� 20 ��,�������
 CALL INIT_TIMER
 MOVF OUT_2,0 
 ANDWF PORTD         ;��������� � W � PORTB
 INCF COUNT2
 RLF OUT_2
LOOP3
 BTFSS PORTB,4
 GOTO LOOP3
 GOTO MAIN2

INIT_TIMER 
  MOVLW 0X81  ;������� OPTION
  MOVWF FSR 
  MOVLW 0X87
  MOVWF INDF 
  MOVLW .2
  MOVWF TMR0
  MOVLW 0xA0
  MOVWF INTCON
  MOVLW 0x00
  MOVWF COUNT_T
  MOVLW  0X01   ;������� �������� W
  RETURN
  
INTERRUPT_TIMER
  BCF INTCON,T0IF
  MOVLW 0xA0
  MOVWF INTCON
  MOVLW .2
  MOVWF TMR0
  INCF COUNT_T
  BTFSC COUNT_T,7 ;�������� ���������� ��� ��������
  CALL Run_Fire
  BTFSS PORTB,4 ;�������� ������ �� RB4
  RETURN
  MOVLW 0x00
  MOVWF INTCON   ;��������� ����������
  RETURN

Run_Fire
  MOVLW 0x00
  MOVWF INTCON      ;���������� ���������� ����������
  MOVLW 0X00

  MOVWF COUNT1
  MOVLW 0X01
  MOVWF  OUT
  MOVLW 0X00
  MOVWF COUNT2
  MOVLW B'11111110'
  MOVWF OUT_2
LOOP4             ;�������� ����������
  MOVF OUT,0          ;� W
  IORWF PORTD
  CALL  DELAY_FIRE
  BTFSC PORTB,4   ;RB4 ���� 1 �� ����
  GOTO INIT2
  INCF COUNT1
  RLF OUT
  BTFSC COUNT1,3
  GOTO LOOP5
  GOTO LOOP4
LOOP5             ;����� ����������
  MOVF OUT_2,0
  ANDWF PORTD
  CALL  DELAY_FIRE
  BTFSC PORTB,4   ;RB4 ���� 1 �� ����
  GOTO INIT2
  INCF COUNT2
  RLF OUT_2
  BTFSC COUNT2,3
  GOTO Run_Fire
  GOTO LOOP5
  
DELAY_RB4          ;������������ �������� �� 250 ��,RA0           
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
  MOVLW       0X01  ;������� �������� W
  RETURN

DELAY_FIRE           ;�������� 100��
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
