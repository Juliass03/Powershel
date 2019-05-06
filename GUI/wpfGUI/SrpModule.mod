MODULE SrpModule
    CONST robtarget mechanicalOrigin:=[[1251.91,0.00,1502.50],[0.5,1.29048E-08,0.866025,7.45058E-09],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    PERS bool isEnd;
    PERS bool moveLoop;
    PERS bool flag1;
    PERS bool flag2;
    PERS bool isInit;
    PERS num speedLevel1;
    PERS num speedLevel2;
    PERS pos offset1;
    PERS pos offset2;
    PERS robtarget lastTarget;
    PERS robtarget pointTarget;
    PERS num mark;
    
    
    
    
    FUNC bool init()
        isEnd := FALSE;
        moveLoop := TRUE;
        flag1 := FALSE;
        flag2 := FALSE;
        isInit := FALSE;
        speedLevel1 := 7;
        speedLevel2 := 0;
        offset1 := [0,0,0];
        offset2 := [0,0,0];
        lastTarget := mechanicalOrigin;
        pointTarget := mechanicalOrigin;
        mark := 0;
        RETURN TRUE;
    ENDFUNC
    
    FUNC speeddata shifting(num base)
        IF base = 0 THEN RETURN v200;
        ELSEIF base = 1 THEN RETURN v300;
        ELSEIF base = 2 THEN RETURN v600;
        ELSEIF base = 3 THEN RETURN v1000;
        ELSEIF base = 4 THEN RETURN v1500;
        ELSEIF base = 5 THEN RETURN v2000;
        ELSEIF base = 6 THEN RETURN v2500;
        ELSEIF base = 7 THEN RETURN v3000;
        ELSE RETURN v100;
        ENDIF
    ENDFUNC
    
    
    PROC MoveLOffset(pos offset,num speedLevel)
        VAR speeddata currentSpeed;
        currentSpeed := shifting(speedLevel);
        MoveL Offs(lastTarget,offset.x,offset.y,offset.z),currentSpeed,z100,tool0\WObj:=wobj0;
    ENDPROC
    
    PROC MoveLPoint(robtarget pointPos,num speedLevel)
        VAR speeddata currentSpeed;
        currentSpeed := shifting(speedLevel);
        MoveL pointPos,currentSpeed,z100,tool0\WObj:=wobj0;
    ENDPROC
    
    
	PROC main()
        IF init() = TRUE THEN
            ConfL \Off;
            SingArea \Wrist;
            MoveL mechanicalOrigin,v200,z100,tool0\WObj:=wobj0;
            isInit := TRUE;
            WHILE moveLoop DO
                WaitUntil flag1 = TRUE;
                !MoveLOffset offset1,speedLevel1;
                MoveLPoint pointTarget,speedLevel1;
                mark := 1;
                flag1 := FALSE;
                !WaitUntil flag2 = TRUE;
                !MoveLOffset offset2,speedLevel2;
                !mark := 2;
                !flag2 := FALSE;
            ENDWHILE
        ENDIF
        isEnd := TRUE;
	ENDPROC
ENDMODULE