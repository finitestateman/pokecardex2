select t.*, (
        select array_agg (ot.name)
        from origin_type ot
        where
            ot.id = ANY (t.origin_type)
    )
from type t;

select * from origin_type order by id;

select * from type order by id;

select name, (
        select name
        from type
        where
            id = te.attack_type_id
    )
from type t
    join public.type_efficiency te on t.id = te.defense_type_id;

select m.name, (
        select *
        from me
        where
    )
from move m
    join public.move_energy me on move.id = me.move_id;

SELECT m.name AS move_name, t.name AS energy_type, me.quantity
FROM
    move m
    JOIN move_energy me ON m.id = me.move_id
    JOIN type t ON me.type_id = t.id
WHERE
    m.name = 'Vine Whip';

insert into
    move_energy
values (
        (
            select id
            from move
            where
                name = 'Ember'
        ),
        (
            select id
            from type
            where
                name = 'fire'
        ),
        1
    );

select * from pokemon join type;
