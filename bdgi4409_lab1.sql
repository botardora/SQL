--A.

--1. Adjuk meg azokat az autó márkákat melyeket legalább kétszer béreltek MárkaNév,BérlésSzám formában!
select MarkaNev, count(*) as BerlesSzam from Markak m 
join Tipusok t on m.MarkaID=t.MarkaID 
join Autok a on t.TipusID=a.TipusID
join Berel b on a.AutoKod=b.AutoKod
group by MarkaNev
having count(*)>2 

--2. Keressük meg azokat az auto tipusokat, melyek kevesebb mint 600 lej bevételt hoztak(Figyeljetek arra hogy esetlegesen lehet olyan auto is melynek nincs bevétele).
select TipusNev, COALESCE(SUM(NapiDij*(DATEDIFF(day,Mikortol,Meddig))), 0) as Bevetel from Tipusok t
join Autok a on t.TipusID=a.TipusID
left join Berel b on a.AutoKod=b.AutoKod
group by TipusNev
having COALESCE(SUM(NapiDij*(DATEDIFF(day,Mikortol,Meddig))), 0) < 600

--3. Adjuk meg azokat a bérlőket akik csak Volkswagen Polo-t béreltek.
select Nev from Berlok be 
join Berel b on be.BerloID=b.BerloID
join Autok a on b.AutoKod=a.AutoKod
join Tipusok t on a.TipusID=t.TipusID
where TipusNev='Polo'

--4. Adjuk meg azokat a bérlőket akik extra nélküli autót béreltek.
select Nev from Berlok be
join Berel b on be.BerloID=b.BerloID
join Autok a on b.AutoKod=a.AutoKod
left join AutoExtraja e on a.AutoKod=e.AutoKod
where e.AutoKod is NULL

--5. Adjuk meg a bérlők esetén hogy melyik tipusu autót átlagban hány napra béreltek.
select Nev, TipusNev, AVG(DATEDIFF(day,Mikortol, Meddig)) as Atlag_Berlesi_ido from Berlok be 
join Berel b on be.BerloID=b.BerloID
join Autok a on b.AutoKod=a.AutoKod
join Tipusok t on a.TipusID=t.TipusID
group by Nev, TipusNev

/*ez a berlok neve nelkul van, szerintem igy jobban latszik az atlag\r\n",
select TipusNev, AVG(DATEDIFF(day,Mikortol, Meddig)) as Atlag_Berlesi_ido from Berel b
join Autok a on b.AutoKod=a.AutoKod
join Tipusok t on a.TipusID=t.TipusID
group by TipusNev*/

--6. Adjuk meg csokkenő sorrendben minden autó tipus esetén hány kulőnböző extrával van felszerelve (MárkaNév, TipusNév, ExtrákSzáma). 
--Figyeljetek arra, hogy azok az autók is megjelenjenek melyeknek nincs egyáltalán extra felszereltsége.
select MarkaNev, TipusNev, COUNT(distinct e.ExtraID) as ExtrakSzama from Markak m 
join Tipusok t on m.MarkaID=t.MarkaID
join Autok a on t.TipusID=a.TipusID
left join AutoExtraja e on a.AutoKod=e.AutoKod
group by MarkaNev, TipusNev
order by ExtrakSzama DESC

--7. Halmazmúveletekkel adjuk meg azokat az autokat (MárkaNév, TipusNev, Szin, GyártásiEv) formában 
-- -  Melyeket 2009 után gyártottak de nem piros szinuek.
select MarkaNev, TipusNev, SzinNev as Szin, GyartasiEv from Markak m
join Tipusok t on m.MarkaID=t.MarkaID
join Autok a on t.TipusID=a.TipusID
join Szinek sz on a.SzinKod=sz.SzinKod
where GyartasiEv > 2009
except
select MarkaNev, TipusNev, SzinNev as Szin, GyartasiEv from Markak m
join Tipusok t on m.MarkaID=t.MarkaID
join Autok a on t.TipusID=a.TipusID
join Szinek sz on a.SzinKod=sz.SzinKod
where SzinNev='piros'

-- - Melyekben van Klima és van GPS is
select MarkaNev, TipusNev, GyartasiEv from Markak m 
join Tipusok t on m.MarkaID=t.MarkaID
join Autok a on t.TipusID=a.TipusID
join AutoExtraja e on a.AutoKod=e.AutoKod
join Extrak ex on e.ExtraID=ex.ExtraID
where ExtraNev='Klima'
INTERSECT
select MarkaNev, TipusNev, GyartasiEv from Markak m 
join Tipusok t on m.MarkaID=t.MarkaID
join Autok a on t.TipusID=a.TipusID
join AutoExtraja e on a.AutoKod=e.AutoKod
join Extrak ex on e.ExtraID=ex.ExtraID
where ExtraNev='GPS'

--B. 
--1.Növeljük a napi diját az összes Volkswagen márkájú autónak 10%-al.
update a
set a.NapiDij=a.NapiDij * 1.1 from Autok a
join Tipusok t on a.TipusID=t.TipusID
join Markak m on t.MarkaID=m.MarkaID
where m.MarkaNev='Volkswagen'

--2.Töröljuk az összes 2000 ás 1990 között gyártott autót!
delete from Berel 
from Berel b
join Autok a on a.AutoKod=b.AutoKod
where a.GyartasiEv between 1990 and 2000
                
delete from AutoExtraja
from AutoExtraja e
join Autok a on a.AutoKod=e.AutoKod
where a.GyartasiEv between 1990 and 2000
                
delete from Extrak
from Extrak ex
join AutoExtraja e on ex.ExtraID=e.ExtraID
join Autok a on a.AutoKod=e.AutoKod
where a.GyartasiEv between 1990 and 2000
                
delete from Autok
where GyartasiEv between 1990 and 2000

--3.Szúrd be a kedvenc autód az adatbázisba (legalább 2 extrával)
INSERT INTO Autok (Rendszam,TipusID,SzinKod,GyartasiEv,NapiDij,Csillag)
VALUES ('CJ 05TDW',4,1,2008,20,4)
INSERT INTO AutoExtraja (AutoKod,ExtraID)
VALUES (16, 1)
INSERT INTO AutoExtraja (AutoKod,ExtraID)
VALUES (16, 4)
INSERT INTO Autok (Rendszam,TipusID,SzinKod,GyartasiEv,NapiDij,Csillag)
VALUES ('CJ 05BDM',1,3,2020,180,5)
INSERT INTO AutoExtraja (AutoKod,ExtraID)
VALUES (17, 4)
INSERT INTO AutoExtraja (AutoKod,ExtraID)
VALUES (17, 5)
INSERT INTO AutoExtraja (AutoKod,ExtraID)
VALUES (17, 3)
INSERT INTO AutoExtraja (AutoKod,ExtraID)
VALUES (17, 1)