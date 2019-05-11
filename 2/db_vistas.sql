drop database control_trafico


select cg2.valor as tipo_vehiculo, count(v.id_vehiculo) as cantidad, c.id_dispositivo , (datepart(hour, c.fechahora)) as hora
from control c inner join vehiculo v on c.id_vehiculo = v.id_vehiculo
				inner join catalogo_generico cg on v.modelo = cg.id_catalogo_generico
				inner join catalogo_generico cg2 on cg.parental = cg2.id_catalogo_generico
--where cg.parental = 1
group by c.id_dispositivo, c.fechahora, cg2.valor, v.id_vehiculo, fechahora
order by c.id_dispositivo, hora

CREATE VIEW multas_excesopersonas
AS
select v.placa, cg.valor as modelo, v.anno
from multa m inner join control c on m.id_control = c.id_control
				inner join vehiculo v on v.id_vehiculo = c.id_control
				inner join catalogo_generico cg on cg.id_catalogo_generico = v.modelo
where m.motivo = 'Exceso de Pasajeros'
group by cg.valor, v.placa, v.anno

select * from multa


CREATE VIEW multas_excesovelocidad 
AS
select  v.placa, cg.valor as modelo, v.anno
from multa m inner join control c on m.id_control = c.id_control
			inner join vehiculo v on v.id_vehiculo = c.id_vehiculo
			inner join catalogo_generico cg on cg.id_catalogo_generico = v.modelo
where m.motivo = 'Exceso de Velocidad'
group by cg.valor, v.placa, v.anno
--order by v.placa
go

CREATE VIEW regsitro_multas
AS
select m.motivo, v.placa, v.anno, cg.valor, l.id_licencia, c.fechahora
from multa m inner join control c on m.id_control = c.id_control
			inner join licencia l on l.id_licencia = c.id_licencia
			inner join vehiculo_licencia vl on l.id_licencia = vl.id_vehiculo
			inner join vehiculo v on v.id_vehiculo = c.id_vehiculo
			inner join catalogo_generico cg on cg.id_catalogo_generico = v.modelo


select  c.id_dispositivo, DATEDIFF(year,l.fecha_nacimiento,GETDATE()) as edad
from licencia l inner join control c on c.id_licencia = l.id_licencia
where 
group by c.id_dispositivo, l.fecha_nacimiento

CREATE VIEW automotores_conductores_noautorizados
AS
select count(distinct v.id_vehiculo) as cantidad_automotores
from control c inner join vehiculo v on c.id_vehiculo = v.id_vehiculo
			right join vehiculo_licencia vl on v.id_vehiculo = vl.id_vehiculo
where (c.id_vehiculo = vl.id_vehiculo and c.id_licencia != vl.id_licencia)
--group by v.id_vehiculo

select * from multa

select * from vehiculo

select * from control
