--BOTAR DORA GAZDASAGI INFORMATIKA bdgi4409

--1.SELECT utasítás segítségével adjuk meg minden kocsma esetén, hogy mennyire “népszerű” (KocsmaNev, Népszerűség) formában, ahol:
--ha több, mint 4 barát kedveli, akkor: Népszerűség értéke: ‘Magas’
--ha 2-3 barát kedveli, akkor: Népszerűség értéke: ‘Elfogadhato’
--ha kevesebb, mint 2 barát kedveli, akkor: Népszerűség értéke: ‘Alacsony’

/*SELECT Kocsmak.Nev AS KocsmaNev,
       CASE 
           WHEN COUNT(Kedvencek.BaratID) > 4 THEN 'Magas'
           WHEN COUNT(Kedvencek.BaratID) >= 2 AND COUNT(Kedvencek.BaratID) <= 3 THEN 'Elfogadhato'
           ELSE 'Alacsony'
       END AS Nepszeruseg
FROM Kocsmak
LEFT JOIN Kedvencek ON Kocsmak.KocsmaID = Kedvencek.KocsmaID
GROUP BY Kocsmak.Nev, Kocsmak.KocsmaID*/

--2.Írjunk tárolt eljárást, melynek bemenő paramétere egy természetes szám (@pSzam), kimeneti paramétere: @pOut-int típusú! 
--Ha @pSzam<0, írjunk ki megfelelő hibaüzenetet, valamint @pOut = -1! Ellenkező esetben, írassuk ki azon kocsmá(ka)t (KocsmaNev), 
--mely(ek)ben kevesebb italtípusból válogathatunk, mint a paraméterként megadott szám (0 is lehet a szám)! Ekkor @pOut=a feltételnek 
--eleget tevő kocsmák száma! Ha nincs egyetlen ilyen kocsma sem, írassunk ki megfelelő figyelmeztető üzenetet is!

CREATE PROCEDURE KocsmakItaltipus (
    @pSzam INT,
    @pOut INT OUTPUT
)
AS
BEGIN
    IF @pSzam<0
    BEGIN
        PRINT 'Hiba: a megadott szam negativ'
        SET @pOut=-1
    END
    ELSE
    BEGIN
        
        SELECT k.Nev AS KocsmaNev
        FROM Kocsmak k
        LEFT JOIN Arak a ON k.KocsmaID = a.KocsmaID
        LEFT JOIN Italok i ON a.ItalID = i.ItalID
        GROUP BY k.KocsmaID, k.Nev
        HAVING COUNT(DISTINCT i.TipusID) < @pSzam OR (@pSzam = 0 AND COUNT(DISTINCT i.TipusID) = 0)

        SET @pOut = @@ROWCOUNT

        IF @pOut = 0
        BEGIN
            PRINT 'Nincs olyan kocsma, ahol kevesebb italtipusból lehet valogatni!'
        END
    END
END

DECLARE @outResult INT
EXEC KocsmakItaltipus @pSzam = 5, @pOut = @outResult OUTPUT
SELECT @outResult AS Result

DROP PROCEDURE dbo.KocsmakItaltipus, dbo.KocsmakItaltipusSzam, dbo.KocsmakItaltipusSzama, dbo.KocsmakItaltipusSzamok
go