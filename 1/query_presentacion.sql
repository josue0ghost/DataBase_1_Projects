--Query: clientes mayores de 30 años que comparten cuentas

use banco_micolchon
go

declare @cant_cuentas_cliente table
(
	id_client int,
	cantidad_cuentas int
)
insert into @cant_cuentas_cliente
select
	c.id_cliente as id_client, COUNT(cc.id_cliente_cuenta) as cantidad_cuentas
from
	cliente as c
	join cliente_cuenta as cc on c.id_cliente = cc.id_cliente
	join cuenta as co on cc.id_cuenta = co.id_cuenta
	join catalogo_generico as cat on co.id_tipo = cat.id_catalogo_generico
where
	DATEDIFF(YEAR,c.fecha_nacimiento,GETDATE()) >= 30 and
	cat.valor = 'MONETARIA'
group by
	c.id_cliente


select
	c.*
from
	cliente as c
where
	c.id_cliente in (
		select
			id_client
		from @cant_cuentas_cliente
		where cantidad_cuentas > 1
	)