SUB DrawBox(yPos AS UBYTE, xPos as UBYTE, width as UBYTE, height as UBYTE, boxChars as STRING)
    PRINT AT yPos,xPos;boxChars(0);
    for i = xPos to xPos + width - 3
        PRINT boxChars(1);
    next
    PRINT boxChars(2)

    for i = 1 to height - 2
        PRINT AT yPos + i,xPos;boxChars(3)
        PRINT AT yPos + i,xPos + width - 1;boxChars(4)
    next

    PRINT AT yPos + height - 1,xPos;boxChars(5);
    for i = xPos to xPos + width - 3
        PRINT boxChars(6);
    next
    PRINT boxChars(7)

END SUB
