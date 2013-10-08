__interrupt_vect:
	ljmp	__sdcc_gsinit_startup
__interrupts:
	ljmp	_SIG_INTERRUPT0
__LINKED_LIBS:
	ljmp	__sdcc_program_startup
__sdcc_program_startup:
	lcall	_main
	sjmp .
___nesc_atomic_start:
	mov	c,_EA
	clr	a
	rlc	a
	mov	r7,a
	clr	_EA
	mov	dpl,r7
	ret
___nesc_atomic_end:
	mov	a,dpl
	mov	dptr,#___nesc_atomic_end_oldSreg_1_1
	movx	@dptr,a
	add	a,#0xff
	mov	_EA,c
	ret
_SchedulerBasicP__Scheduler__init:
	mov	dptr,#_memset_PARM_2
	mov	a,#0xFF
	movx	@dptr,a
	mov	dptr,#_memset_PARM_3
	mov	a,#0x02
	movx	@dptr,a
	inc	dptr
	clr	a
	movx	@dptr,a
	mov	dptr,#_SchedulerBasicP__m_next
	mov	b,#0x00
	lcall	_memset
	mov	dptr,#_SchedulerBasicP__m_head
	mov	a,#0xFF
	movx	@dptr,a
	mov	dptr,#_SchedulerBasicP__m_tail
	mov	a,#0xFF
	movx	@dptr,a
	ret
_RealMainP__Scheduler__init:
	ljmp	_SchedulerBasicP__Scheduler__init
_HplMcs51GeneralIOC__P13__clr:
	clr	_P1_3
	ret
_ReverseGPIOP__1__In__clr:
	ljmp	_HplMcs51GeneralIOC__P13__clr
_ReverseGPIOP__1__Out__set:
	ljmp	_ReverseGPIOP__1__In__clr
_LedsP__Led2__set:
	ljmp	_ReverseGPIOP__1__Out__set
_NoPinC__0__GeneralIO__set:
	ret
_LedsP__Led1__set:
	ljmp	_NoPinC__0__GeneralIO__set
_HplMcs51GeneralIOC__P10__clr:
	clr	_P1_0
	ret
_ReverseGPIOP__0__In__clr:
	ljmp	_HplMcs51GeneralIOC__P10__clr
_ReverseGPIOP__0__Out__set:
	ljmp	_ReverseGPIOP__0__In__clr
_LedsP__Led0__set:
	ljmp	_ReverseGPIOP__0__Out__set
_HplMcs51GeneralIOC__P13__makeOutput:
	orl	_P1_DIR,#0x08
	ret
_ReverseGPIOP__1__In__makeOutput:
	ljmp	_HplMcs51GeneralIOC__P13__makeOutput
_ReverseGPIOP__1__Out__makeOutput:
	ljmp	_ReverseGPIOP__1__In__makeOutput
_LedsP__Led2__makeOutput:
	ljmp	_ReverseGPIOP__1__Out__makeOutput
_NoPinC__0__GeneralIO__makeOutput:
	ret
_LedsP__Led1__makeOutput:
	ljmp	_NoPinC__0__GeneralIO__makeOutput
_HplMcs51GeneralIOC__P10__makeOutput:
	orl	_P1_DIR,#0x01
	ret
_ReverseGPIOP__0__In__makeOutput:
	ljmp	_HplMcs51GeneralIOC__P10__makeOutput
_ReverseGPIOP__0__Out__makeOutput:
	ljmp	_ReverseGPIOP__0__In__makeOutput
_LedsP__Led0__makeOutput:
	ljmp	_ReverseGPIOP__0__Out__makeOutput
_LedsP__Init__init:
	lcall	_LedsP__Led0__makeOutput
	lcall	_LedsP__Led1__makeOutput
	lcall	_LedsP__Led2__makeOutput
	lcall	_LedsP__Led0__set
	lcall	_LedsP__Led1__set
	lcall	_LedsP__Led2__set
	mov	dpl,#0x00
	ret
_PlatformP__LedsInit__init:
	ljmp	_LedsP__Init__init
_PlatformP__Init__init:
	mov	r7,_SLEEP
	anl	ar7,#0xFC
	mov	_SLEEP,r7
	mov	r7,_SLEEP
	anl	ar7,#0xFB
	mov	_SLEEP,r7
__UQ__1:
	mov	a,_SLEEP
	jnb	acc.6,__UQ__1
	mov	_CLKCON,#0x08
	lcall	_PlatformP__LedsInit__init
	mov	dpl,#0x00
	ret
_RealMainP__PlatformInit__init:
	ljmp	_PlatformP__Init__init
_RealMainP__Scheduler__runNextTask:
	ljmp	_SchedulerBasicP__Scheduler__runNextTask
_BlinkNoTimerTaskC__toggle__postTask:
	mov	dpl,#0x00
	ljmp	_SchedulerBasicP__TaskBasic__postTask
_SchedulerBasicP__isWaiting:
	mov	a,dpl
	mov	dptr,#_SchedulerBasicP__isWaiting_id_1_1
	movx	@dptr,a
	mov	r7,a
	add	a,#_SchedulerBasicP__m_next
	mov	dpl,a
	clr	a
	addc	a,#(_SchedulerBasicP__m_next >> 8)
	mov	dph,a
	movx	a,@dptr
	mov	r6,a
	clr	a
	cjne	r6,#0xFF,__UQ__2
	inc	a
__UQ__2:
	mov	r6,a
	cjne	a,#0x01,__UQ__3
__UQ__3:
	clr	a
	rlc	a
	mov	r6,a
	jnz	__UQ__4
	mov	dptr,#_SchedulerBasicP__m_tail
	movx	a,@dptr
	mov	r6,a
	cjne	a,ar7,__UQ__5
	sjmp	__UQ__4
__UQ__5:
	mov	r7,#0x00
	sjmp	__UQ__6
__UQ__4:
	mov	r7,#0x01
__UQ__6:
	mov	dpl,r7
	ret
_SchedulerBasicP__pushTask:
	mov	a,dpl
	mov	dptr,#_SchedulerBasicP__pushTask_id_1_1
	movx	@dptr,a
	mov	r7,a
	mov	dpl,a
	push	ar7
	lcall	_SchedulerBasicP__isWaiting
	mov	a,dpl
	pop	ar7
	jnz	__UQ__7
	mov	dptr,#_SchedulerBasicP__m_head
	movx	a,@dptr
	mov	r6,a
	cjne	r6,#0xFF,__UQ__8
	mov	dptr,#_SchedulerBasicP__m_head
	mov	a,r7
	movx	@dptr,a
	mov	dptr,#_SchedulerBasicP__m_tail
	mov	a,r7
	movx	@dptr,a
	sjmp	__UQ__9
__UQ__8:
	mov	dptr,#_SchedulerBasicP__m_tail
	movx	a,@dptr
	mov	r6,a
	add	a,#_SchedulerBasicP__m_next
	mov	dpl,a
	clr	a
	addc	a,#(_SchedulerBasicP__m_next >> 8)
	mov	dph,a
	mov	a,r7
	movx	@dptr,a
	mov	dptr,#_SchedulerBasicP__m_tail
	mov	a,r7
	movx	@dptr,a
__UQ__9:
	mov	dpl,#0x01
	ret
__UQ__7:
	mov	dpl,#0x00
	ret
_HplMcs51GeneralIOC__P10__toggle:
	setb	_P1_0
	ret
_ReverseGPIOP__0__In__toggle:
	ljmp	_HplMcs51GeneralIOC__P10__toggle
_ReverseGPIOP__0__Out__toggle:
	lcall	___nesc_atomic_start
	mov	r7,dpl
	push	ar7
	lcall	_ReverseGPIOP__0__In__toggle
	pop	ar7
	mov	dpl,r7
	ljmp	___nesc_atomic_end
_LedsP__Led0__toggle:
	ljmp	_ReverseGPIOP__0__Out__toggle
_LedsP__Leds__led0Toggle:
	ljmp	_LedsP__Led0__toggle
_BlinkNoTimerTaskC__Leds__led0Toggle:
	ljmp	_LedsP__Leds__led0Toggle
_NoPinC__0__GeneralIO__toggle:
	ret
_LedsP__Led1__toggle:
	ljmp	_NoPinC__0__GeneralIO__toggle
_LedsP__Leds__led1Toggle:
	ljmp	_LedsP__Led1__toggle
_BlinkNoTimerTaskC__Leds__led1Toggle:
	ljmp	_LedsP__Leds__led1Toggle
_HplMcs51GeneralIOC__P13__toggle:
	setb	_P1_3
	ret
_ReverseGPIOP__1__In__toggle:
	ljmp	_HplMcs51GeneralIOC__P13__toggle
_ReverseGPIOP__1__Out__toggle:
	lcall	___nesc_atomic_start
	mov	r7,dpl
	push	ar7
	lcall	_ReverseGPIOP__1__In__toggle
	pop	ar7
	mov	dpl,r7
	ljmp	___nesc_atomic_end
_LedsP__Led2__toggle:
	ljmp	_ReverseGPIOP__1__Out__toggle
_LedsP__Leds__led2Toggle:
	ljmp	_LedsP__Led2__toggle
_BlinkNoTimerTaskC__Leds__led2Toggle:
	ljmp	_LedsP__Leds__led2Toggle
_RealMainP__SoftwareInit__default__init:
	mov	dpl,#0x00
	ret
_RealMainP__SoftwareInit__init:
	ljmp	_RealMainP__SoftwareInit__default__init
_BlinkNoTimerTaskC__delay__postTask:
	mov	dpl,#0x01
	ljmp	_SchedulerBasicP__TaskBasic__postTask
_HplMcs51GeneralIOC__P13__set:
	setb	_P1_3
	ret
_ReverseGPIOP__1__In__set:
	ljmp	_HplMcs51GeneralIOC__P13__set
_ReverseGPIOP__1__Out__clr:
	ljmp	_ReverseGPIOP__1__In__set
_LedsP__Led2__clr:
	ljmp	_ReverseGPIOP__1__Out__clr
_LedsP__Leds__led2On:
	ljmp	_LedsP__Led2__clr
_BlinkNoTimerTaskC__Leds__led2On:
	ljmp	_LedsP__Leds__led2On
_NoPinC__0__GeneralIO__clr:
	ret
_LedsP__Led1__clr:
	ljmp	_NoPinC__0__GeneralIO__clr
_LedsP__Leds__led1On:
	ljmp	_LedsP__Led1__clr
_BlinkNoTimerTaskC__Leds__led1On:
	ljmp	_LedsP__Leds__led1On
_HplMcs51GeneralIOC__P10__set:
	setb	_P1_0
	ret
_ReverseGPIOP__0__In__set:
	ljmp	_HplMcs51GeneralIOC__P10__set
_ReverseGPIOP__0__Out__clr:
	ljmp	_ReverseGPIOP__0__In__set
_LedsP__Led0__clr:
	ljmp	_ReverseGPIOP__0__Out__clr
_LedsP__Leds__led0On:
	ljmp	_LedsP__Led0__clr
_BlinkNoTimerTaskC__Leds__led0On:
	ljmp	_LedsP__Leds__led0On
_BlinkNoTimerTaskC__Boot__booted:
	lcall	_BlinkNoTimerTaskC__Leds__led0On
	lcall	_BlinkNoTimerTaskC__Leds__led1On
	lcall	_BlinkNoTimerTaskC__Leds__led2On
	ljmp	_BlinkNoTimerTaskC__delay__postTask
_RealMainP__Boot__booted:
	ljmp	_BlinkNoTimerTaskC__Boot__booted
_SchedulerBasicP__TaskBasic__default__runTask:
	ret
_SchedulerBasicP__TaskBasic__runTask:
	mov	a,dpl
	mov	dptr,#_SchedulerBasicP__TaskBasic__runTask_arg_0x2ace41fc53c8_1_1
	movx	@dptr,a
	mov	r7,a
	mov	r5,a
	mov	r6,#0x00
	cjne	r5,#0x00,__UQ__10
	cjne	r6,#0x00,__UQ__10
	sjmp	__UQ__11
__UQ__10:
	cjne	r5,#0x01,__UQ__12
	cjne	r6,#0x00,__UQ__12
	sjmp	__UQ__13
__UQ__11:
	ljmp	_BlinkNoTimerTaskC__toggle__runTask
__UQ__13:
	ljmp	_BlinkNoTimerTaskC__delay__runTask
__UQ__12:
	mov	dpl,r7
	ljmp	_SchedulerBasicP__TaskBasic__default__runTask
___nesc_disable_interrupt:
	clr	_EA
	ret
___nesc_enable_interrupt:
	setb	_EA
	ret
_McuSleepC__McuSleep__sleep:
	lcall	___nesc_enable_interrupt
	mov	r7,_SLEEP
	anl	ar7,#0xFC
	mov	_SLEEP,r7
	ljmp	___nesc_disable_interrupt
_SchedulerBasicP__McuSleep__sleep:
	ljmp	_McuSleepC__McuSleep__sleep
_SchedulerBasicP__popTask:
	mov	dptr,#_SchedulerBasicP__m_head
	movx	a,@dptr
	mov	r7,a
	cjne	r7,#0xFF,__UQ__14
	sjmp	__UQ__15
__UQ__14:
	mov	dptr,#_SchedulerBasicP__m_head
	movx	a,@dptr
	mov	r7,a
	mov	dptr,#_SchedulerBasicP__m_head
	movx	a,@dptr
	add	a,#_SchedulerBasicP__m_next
	mov	dpl,a
	clr	a
	addc	a,#(_SchedulerBasicP__m_next >> 8)
	mov	dph,a
	movx	a,@dptr
	mov	dptr,#_SchedulerBasicP__m_head
	movx	@dptr,a
	mov	dptr,#_SchedulerBasicP__m_head
	movx	a,@dptr
	mov	r6,a
	cjne	r6,#0xFF,__UQ__16
	mov	dptr,#_SchedulerBasicP__m_tail
	mov	a,#0xFF
	movx	@dptr,a
__UQ__16:
	mov	a,r7
	add	a,#_SchedulerBasicP__m_next
	mov	dpl,a
	clr	a
	addc	a,#(_SchedulerBasicP__m_next >> 8)
	mov	dph,a
	mov	a,#0xFF
	movx	@dptr,a
	mov	dpl,r7
	ret
__UQ__15:
	mov	dpl,#0xFF
	ret
_SchedulerBasicP__Scheduler__taskLoop:
__UQ__17:
	lcall	___nesc_atomic_start
	mov	r7,dpl
__UQ__18:
	push	ar7
	lcall	_SchedulerBasicP__popTask
	mov	r6,dpl
	pop	ar7
	cjne	r6,#0xFF,__UQ__19
	push	ar7
	lcall	_SchedulerBasicP__McuSleep__sleep
	pop	ar7
	sjmp	__UQ__18
__UQ__19:
	mov	dpl,r7
	push	ar6
	lcall	___nesc_atomic_end
	pop	ar6
	mov	dpl,r6
	lcall	_SchedulerBasicP__TaskBasic__runTask
	sjmp	__UQ__17
_RealMainP__Scheduler__taskLoop:
	ljmp	_SchedulerBasicP__Scheduler__taskLoop
_main:
	lcall	___nesc_atomic_start
	mov	r7,dpl
	push	ar7
	lcall	_RealMainP__Scheduler__init
	lcall	_RealMainP__PlatformInit__init
	pop	ar7
__UQ__20:
	push	ar7
	lcall	_RealMainP__Scheduler__runNextTask
	mov	a,dpl
	pop	ar7
	jnz	__UQ__20
	push	ar7
	lcall	_RealMainP__SoftwareInit__init
	pop	ar7
__UQ__21:
	push	ar7
	lcall	_RealMainP__Scheduler__runNextTask
	mov	a,dpl
	pop	ar7
	jnz	__UQ__21
	mov	dpl,r7
	lcall	___nesc_atomic_end
	lcall	___nesc_enable_interrupt
	lcall	_RealMainP__Boot__booted
	lcall	_RealMainP__Scheduler__taskLoop
	mov	dptr,#0xFFFF
	ret
_SchedulerBasicP__Scheduler__runNextTask:
	lcall	_SchedulerBasicP__popTask
	mov	r7,dpl
	cjne	r7,#0xFF,__UQ__22
	mov	dpl,#0x00
	ret
__UQ__22:
	mov	dpl,r7
	lcall	_SchedulerBasicP__TaskBasic__runTask
	mov	dpl,#0x01
	ret
_BlinkNoTimerTaskC__delay__runTask:
	mov	r6,#0x00
	mov	r7,#0x00
__UQ__23:
	clr	c
	mov	a,r6
	subb	a,#0xFF
	mov	a,r7
	subb	a,#0x01
	jnc	__UQ__24
	mov	r4,#0xA0
	mov	r5,#0x00
__UQ__25:
	dec	r4
	cjne	r4,#0xFF,__UQ__26
	dec	r5
__UQ__26:
	mov	a,r4
	orl	a,r5
	jnz	__UQ__25
	inc	r6
	cjne	r6,#0x00,__UQ__23
	inc	r7
	sjmp	__UQ__23
__UQ__24:
	lcall	_BlinkNoTimerTaskC__toggle__postTask
	ljmp	_BlinkNoTimerTaskC__delay__postTask
_SchedulerBasicP__TaskBasic__postTask:
	mov	a,dpl
	mov	dptr,#_SchedulerBasicP__TaskBasic__postTask_id_1_1
	movx	@dptr,a
	lcall	___nesc_atomic_start
	mov	r7,dpl
	mov	dptr,#_SchedulerBasicP__TaskBasic__postTask_id_1_1
	movx	a,@dptr
	mov	dpl,a
	push	ar7
	lcall	_SchedulerBasicP__pushTask
	mov	a,dpl
	pop	ar7
	jz	__UQ__27
	mov	r6,#0x00
	sjmp	__UQ__28
__UQ__27:
	mov	r6,#0x05
__UQ__28:
	mov	dpl,r7
	push	ar6
	lcall	___nesc_atomic_end
	pop	ar6
	mov	dpl,r6
	ret
_BlinkNoTimerTaskC__toggle__runTask:
	mov	dptr,#_BlinkNoTimerTaskC__cntr
	movx	a,@dptr
	mov	r6,a
	inc	dptr
	movx	a,@dptr
	mov	r7,a
	mov	dptr,#__modsint_PARM_2
	mov	a,#0x02
	movx	@dptr,a
	inc	dptr
	clr	a
	movx	@dptr,a
	mov	dpl,r6
	mov	dph,r7
	lcall	__modsint
	mov	a,dpl
	mov	b,dph
	orl	a,b
	jz	__UQ__29
	lcall	_BlinkNoTimerTaskC__Leds__led0Toggle
__UQ__29:
	lcall	_BlinkNoTimerTaskC__Leds__led1Toggle
	ljmp	_BlinkNoTimerTaskC__Leds__led2Toggle
_SIG_INTERRUPT0:
	push	acc
	push	dpl
	push	dph
	push	psw
	mov	dptr,#_BlinkNoTimerTaskC__cntr
	movx	a,@dptr
	add	a,#0x01
	movx	@dptr,a
	inc	dptr
	movx	a,@dptr
	addc	a,#0x00
	movx	@dptr,a
	pop	psw
	pop	dph
	pop	dpl
	pop	acc
	reti
