create type tcg_type as enum ('grass', 'fire', 'water', 'lightning', 'psychic', 'fighting', 'darkness', 'metal', 'dragon', 'colorless');
create type rpg_type as enum ('normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy', 'stellar');
create type trainer as enum ('item', 'pokemon_tool', 'fossil', 'supporter');
-- alter type vg_type rename to rpg_type;
create type rarity as enum ( 'd1', 'd2', 'd3', 'd4', 's1', 's2', 's3', 'c');
-- promo -- common, uncommon, rare, double_rare, art_rare, super_rare, immserive_rare, crown_rare

drop type type;

create table pokemon_card
(
    id uuid default gen_random_uuid() primary key,
    name varchar not null,
    card_no integer,
    stage integer, -- 0: basic, 1: stage 1, 2: stage 2
    ability text,
    evolves_from uuid references pokemon(id), -- 화석 포켓몬 예외처리 필요
    type tcg_type not null,
--     description integer references description(id), -- 1:n -> a card can have 1 description, and a description can be described in any cards(but description.pokemon_id must be equal to pokemon.id)
    pokemon_id uuid references pokemon(id) not null,
    description_id integer,
--     is_ex boolean default false not null,
    ex_rule text,
    attack1 integer references attack(id) not null, -- n:m -> a card can have 2 attacks(moves), and an attack can be used by any pokemon
    attack2 integer references attack(id), -- n:m --> attack1과 2를 분리했으므로 n:m이 아니다
--     series varchar,
--     booster_pack_id integer references booster_pack not null,
    rarity rarity not null,
    offering_rate numeric(6, 3) not null,
    retreat tcg_type[] not null,
    weakness tcg_type not null,
    hp integer not null,
    illustrator_id integer references illustrator,
    pack_points integer,
    constraint fk_card_description foreign key (pokemon_id, description_id) references description(pokemon_id, id)
--     constraint uq_pokemon_card_booster_pack_card_no unique (booster_pack_id, card_no)
);
alter table pokemon_card add constraint unique ()
drop table pokemon_card;

select * from pokemon_card;

alter table pokemon_card alter column attack1  set not null
alter table pokemon_card rename illustrator to illustrator_id;

-- a card can belong to multiple booster packs
create table booster_pack_pokemon_card
(
    booster_pack_id integer references booster_pack(id) not null,
    pokemon_card_id uuid references pokemon_card(id) not null,
    card_no integer references pokemon_card(card_no) not null,
    constraint uk_booster_pack_card_no unique (booster_pack_id, card_no)
);
alter table booster_pack_pokemon_card
alter column card_no set not null;

alter table booster_pack_pokemon_card
add constraint uk_booster_pack_card_no unique (booster_pack_id, card_no);

select * from booster_pack_pokemon_card;
delete from booster_pack_pokemon_card where card_no= 53;


insert into booster_pack_pokemon_card
-- values((select id from booster_pack where name = 'Charizard'), (select id from pokemon_card where name = 'Charmander'))
-- values((select id from booster_pack where name = 'Mewtwo'), (select id from pokemon_card where name = 'Bulbasaur'))
values((select id from booster_pack where name = 'Pikachu'), (select id from pokemon_card where name = 'Squirtle'), 53)


create table trainer_card
(
    id integer primary key,
    kind trainer not null,
    name varchar not null,
    description text not null,
    rarity rarity,
    footnote text,
    illustrator illustrator
);
drop table trainer_card;

create table fossil_card
(
    id integer primary key,
    trainer_card_id integer references trainer_card,
    hp integer not null
--     evolves_to
);
drop table fossil;

create table supporter_card
(

);

create table illustrator
(
    id integer generated always as identity primary key,
    name varchar not null
);
insert into illustrator(name) values('Narumi Sato');
insert into illustrator(name) values('Teeziro');
insert into illustrator(name) values('Mizue');
select * from illustrator;


-- cards can be included in many booster_pack, booster_pack can have many cards

create table card_no
(
    -- 아래 두개가 한꺼번에 unique가 돼야 한다?
    booster_pack_id integer references booster_pack,
    no integer
);


create table trainer_card
(

);

create table item_card
(

);


-- promo card

create table pokemon
(
    id uuid default gen_random_uuid() primary key,
    dex_no integer not null, -- mega 진화 등의 이유로 not unique
    species varchar,
    name varchar not null,
    type1 rpg_type not null,
    type2 rpg_type,
    height integer,
    weight integer,
--     description integer references description(id), -- 1:n -> a card can have 1 description, and a description can be described in any cards(but description.pokemon_id must be equal to pokemon.id)
    introduced_gen generation not null
);
select * from pokemon;

insert into pokemon(dex_no, species, name, type1, type2, height, weight, introduced_gen)
values
    (1, 'Seed Pokémon', 'Bulbasaur','grass'::rpg_type, 'poison'::rpg_type, 70, 69, 1),
    (2, 'Seed Pokémon', 'Ivysaur', 'grass'::rpg_type, 'poison'::rpg_type, 100, 130, 1),
    (3, 'Seed Pokémon', 'Venusaur', 'grass'::rpg_type, 'poison'::rpg_type, 200, 1000, 1),
    (4, 'Lizard Pokémon', 'Charmander', 'fire'::rpg_type, null, 60, 85, 1),
    (5, 'Flame Pokémon', 'Charmeleon', 'fire'::rpg_type, null, 110, 190, 1),
    (6, 'Flame Pokémon', 'Charizard', 'fire'::rpg_type, 'flying'::rpg_type, 170, 905, 1),
    (7, 'Tiny Turtle Pokémon', 'Squirtle', 'water'::rpg_type, null, 50, 90, 1),
    (8, 'Turtle Pokémon', 'Wartortle', 'water'::rpg_type, null, 100, 225, 1),
    (9, 'Shellfish Pokémon', 'Blastoise', 'water'::rpg_type, null, 160, 855, 1);

update pokemon set name = 'Charmander' where dex_no = 4;
delete from pokemon where 1=1;


select
    dex_no,
    species,
    name,
    type1,
    type2,
    height / concat(floor(height / 30.48 - floor(30.48)) * 12, 1) as HT,
    weight / 10.0 as WT,
    description.content
from pokemon join description on pokemon.id = description.pokemon_id;

SELECT
    name,
    height,
    FLOOR(height / 30.48) AS feet,
    ROUND((height / 30.48 - FLOOR(height / 30.48)) * 12, 1) AS inches,
    CONCAT(FLOOR(height / 30.48), '''', ROUND((height / 30.48 - FLOOR(height / 30.48)) * 12, 0), '"') AS height_ft_in,
    round(weight * 0.220462, 1) as lbs
FROM pokemon
order by dex_no asc;

SELECT
    name,
    height,
    FLOOR(height / 30.48) AS feet,
    ROUND((height / 30.48 - FLOOR(height / 30.48)) * 12, 0) AS inches,
    CASE
        WHEN ROUND((height / 30.48 - FLOOR(height / 30.48)) * 12, 0) = 12
        THEN CONCAT(FLOOR(height / 30.48) + 1, '''0"')
        ELSE CONCAT(FLOOR(height / 30.48), '''', ROUND((height / 30.48 - FLOOR(height / 30.48)) * 12, 0), '"')
    END AS height_ft_in
FROM pokemon
ORDER BY dex_no ASC;


-- create img

evolves_to integer[] references pokemon(id[]),
evolves_from integer[] references pokemon(id[])

-- create table generation
-- (
--     id integer generated always as identity primary key,
--     number integer unique not null,
--     name character varying not null
-- );
-- drop table generation cascade;
-- create type generation as enum
-- select *from generation;
create domain generation as integer check (value between 1 and 9);


create table description
(
    id integer generated always as identity primary key,
    content text not null,
    pokemon_id uuid references pokemon(id) on delete cascade not null,
    generation generation,
--     constraint uq_description_pokemon unique (pokemon_id, generation)
    constraint uq_generation_pokemon unique (pokemon_id, generation),
    constraint uq_generation unique (id, pokemon_id)
);
alter table description add constraint;
drop table description;

INSERT INTO description (content, pokemon_id, generation)
VALUES
    ('There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger.', (SELECT id FROM pokemon WHERE dex_no = 1), 1),
    ('When the bulb on its back grows large, it appears to lose the ability to stand on its hind legs.', (SELECT id FROM pokemon WHERE dex_no = 2), 1),
    ('Its plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight.', (SELECT id FROM pokemon WHERE dex_no = 3), 1),
    ('It has a preference for hot things. When it rains, steam is said to spout from the tip of its tail.', (SELECT id FROM pokemon WHERE dex_no = 4), 1),
    ('It has a barbaric nature. In battle, it whips its fiery tail around and slashed away with sharp claws', (SELECT id FROM pokemon WHERE dex_no = 5), 1),
    ('It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.', (SELECT id FROM pokemon WHERE dex_no = 6), 1),
    ('When it retracts its long neck into its shell, it squirts out water with vigorous force.', (SELECT id FROM pokemon WHERE dex_no = 7), 1),
    ('It is recognized as a symbol of longevity. If its shell has algae on it, that Wartortle is very old', (SELECT id FROM pokemon WHERE dex_no = 8), 1),
    ('It crushes its foe under its heavy body to cause fainting. In a pinch, it will withdraw inside its shell', (SELECT id FROM pokemon WHERE dex_no = 9), 1);

select * from description;



select * from region;


create table attack
(
    id integer generated always as identity primary key,
    name varchar unique not null,
    damage integer,
    energies tcg_type[] not null, -- was json before
    description text,
    operator operator
);
drop table attack;

insert into attack(name, damage, energies, description, operator)
values
    ('Vine Whip', 40, ARRAY['grass'::tcg_type, 'colorless'::tcg_type], null, null),
    ('Razor Leaf', 60, ARRAY['grass'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], null, null),
    ('Mega Drain', 80, ARRAY['grass'::tcg_type, 'grass'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'Heal 30 damage from this Pokémon.', null),
    ('Ember', 30, ARRAY['fire'::tcg_type], 'Discard a [fire] Energy from this Pokémon.', null),
    ('Fire Claws', 60, ARRAY['fire'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], null, null),
    ('Fire Spin', 150, ARRAY['fire'::tcg_type, 'fire'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], null, null),
    ('Water Gun', 20, ARRAY['water'::tcg_type], null, null),
    ('Wave Splash', 40, ARRAY['water'::tcg_type, 'colorless'::tcg_type], null, null),
    ('Hydro Pump', 80, ARRAY['water'::tcg_type, 'water'::tcg_type, 'colorless'::tcg_type], 'If this Pokémon has at least 2 extra [water] Energy attached, this attack does 60 more damage.', '+');

select * from attack;

create type operator as enum ('+', '*');

create table expansion
(
    id integer primary key,
    title varchar not null,
    alias varchar not null, -- PROMO-A, A1, , A1a, A2
    series varchar, -- A, A, A, A
    code varchar, -- P-A, A1, A1a, A2
    releasedAt timestamptz

);
alter table expansion ALTER column alias set not null;
select * from expansion;

INSERT INTO expansion (id, title, series, alias, code, releasedAt)
VALUES
    (0, 'PROMO-A', 'A', 'PROMO-A', 'P-A', '2024-10-30 00:00:00 UTC'::timestamptz),
    (1, 'Genetic Apex', 'A', 'A1', 'A1', '2024-10-30 00:00:00 UTC'::timestamptz),
    (2, 'Mythical Island', 'A', 'A1a', 'A1a', '2024-12-17 00:00:00 UTC'::timestamptz),
    (3, 'Space-Time Smackdown', 'A', 'A2', 'A2', '2025-01-30 00:00:00 UTC'::timestamptz);
select * from expansion;


update expansion set series = 'A' where




create table booster_pack
(
    id integer primary key,
    expansion_id integer references expansion(id),
    name varchar not null,
    count integer not null -- is this really necessary?
);
drop table booster_pack;
select * from booster_pack bp
    right join pokemon_card pc on bp.id = pc.booster_pack_id
where pc.booster_pack_id = bp.id;
-- where pc.pokemon_id

insert into booster_pack(id, expansion_id, name, count)
values
    (1, 1, 'Mewtwo', 0),
    (2, 1, 'Pikachu', 0),
    (3, 1, 'Charizard', 0),
    (4, 2, 'Themed Booster Pack', 0),
    (5, 3, 'Diala', 0),
    (6, 3, 'Palkia', 0);

select * from booster_pack join expansion e on booster_pack.expansion_id = e.id;

create table featured_pokemon
(
    id integer generated always as identity primary key,
    pokemon integer references pokemon(id) null
);


-- PROMO-A(p-A)
-- How to obtain: Obtained from a promo pack, Obtained from a wonder pick, Obtained from a mission, Obtained from a campaign, Obtained from the shop ||
select * from description;

create table region
(
    id integer generated always as identity primary key,
    name varchar not null,
    generation generation not null
);
insert into region(name, generation) values ('Kanto', 1), ('Johto', 2), ('Hoenn', 3), ('Sinnoh',4), ('Unova', 5), ('Kalos', 6), ('Alola', 7), ('Galar', 8), ('Paldea',9);

select * from region;


create table attack
(
    id integer generated always as identity primary key,
    name varchar unique not null,
    damage integer,
    operator operator,
    energies tcg_type[] not null, -- was json before
    description text
);

create type operator as enum ('+', '*');

create table expansion
(
    id integer primary key,
    title varchar not null,
    series varchar, -- PROMO-A
    code varchar, -- P-A
    releasedAt timestamptz

);

INSERT INTO expansion (id, title, series, code, releasedAt)
VALUES
    (0, 'PROMO-A', 'PROMO-A', 'P-A', '2024-10-30 00:00:00 UTC'::timestamptz),
    (1, 'Genetic Apex', 'A1', 'A1', '2024-10-30 00:00:00 UTC'::timestamptz),
    (2, 'Mythical Island', 'A1a', 'A1a', '2024-12-17 00:00:00 UTC'::timestamptz),
    (3, 'Space-Time Smackdown', 'A2', 'A2', '2025-01-30 00:00:00 UTC'::timestamptz);
select * from expansion;




create table booster_pack
(
    id integer primary key,
    expansion_id integer references expansion(id),
    name varchar not null,
    count integer not null -- is this really necessary?
);
drop table booster_pack;

insert into booster_pack(id, expansion_id, name, count)
values
    (1, 1, 'Mewtwo', 0),
    (2, 1, 'Pikachu', 0),
    (3, 1, 'Charizard', 0),
    (4, 2, 'Themed Booster Pack', 0),
    (5, 3, 'Diala', 0),
    (6, 3, 'Palkia', 0);

select * from booster_pack join expansion e on booster_pack.expansion_id = e.id;

create table featured_pokemon
(
    id integer generated always as identity primary key,
    pokemon integer references pokemon(id) null
);


-- PROMO-A(p-A)
-- How to obtain: Obtained from a promo pack, Obtained from a wonder pick, Obtained from a mission, Obtained from a campaign, Obtained from the shop


drop table pokemon_card;
insert into pokemon_card (name, card_no, stage, ability, evolves_from, type, pokemon_id, description_id, is_ex, attack1,
                                 attack2, rarity, offering_rate, retreat, weakness, hp, illustrator_id,
                                 pack_points)
values ('Bulbasaur', 1, 0, null, null, 'grass'::tcg_type,
        (SELECT id FROM pokemon where name = 'Bulbasaur'),
        (SELECT id from description where content like 'There%'),
        false,
        (SELECT id FROM attack where name = 'Vine Whip'),
        null,
        'd1',
        2.000,
        ARRAY ['colorless'::tcg_type],
        'fire'::tcg_type,
        70,
        1,
        35
       );


insert into pokemon_card (name, card_no, stage, ability, evolves_from, type, pokemon_id, description_id, is_ex, attack1,
                          attack2, rarity, offering_rate, retreat, weakness, hp, illustrator_id,
                          pack_points)
values ('Charmander', 033, 0, null, null, 'fire'::tcg_type,
        (SELECT id FROM pokemon where name = 'Charmander'),
        (SELECT id from description where content like 'It has a pre%'),
        false,
        (SELECT id FROM attack where name = 'Ember'),
        null,
        'd1',
        2.000,
        ARRAY ['colorless'::tcg_type],
        'water'::tcg_type,
        70,
        2,
        35
       );

select * from pokemon_card;

insert into pokemon_card (name, card_no, stage, ability, evolves_from, type, pokemon_id, description_id, is_ex, attack1,
                          attack2, rarity, offering_rate, retreat, weakness, hp, illustrator_id,
                          pack_points)
values ('Squirtle', 053, 0, null, null, 'water'::tcg_type,
        (SELECT id FROM pokemon where name = 'Squirtle'),
        (SELECT id from description where content like 'When it re%'),
        false,
        (SELECT id FROM attack where name = 'Water Gun'),
        null,
        'd1',
        2.000,
        ARRAY ['colorless'::tcg_type],
        'lightning'::tcg_type,
        60,
        3,
        35
       );
select * from pokemon_card;

delete from pokemon_card where card_no = 53;
select * from pokemon where name != 'Charmander';

update pokemon_card set attack1 = (SELECT id from attack where name = 'Vine Whip') where card_no = 1;
update pokemon_card set booster_pack_id = (SELECT id from booster_pack where  name = 'Mewtwo') where card_no = 1;
update pokemon_card set retreat = (SELECT id from attack where name = 'Vine Whip') where card_no = 1;

UPDATE pokemon_card p
SET retreat = array_remove(retreat, 'fire'::tcg_type)
WHERE card_no = 1;

select * from pokemon;
select * from pokemon_card;
select * from attack;

select
    pc.stage as "stage",
    pc.name as "cardName",
    pc.hp as "HP",
    pc.card_type "cardType",
    (select row_to_json(t)
        from (
            select
                lpad(cast(dex_no as text), 4, '0') as "natlNo",
                species as "species",
                height / 10.0 as "height",
                weight / 10.0 as "weight"
            from pokemon p
            where p.id = pc.pokemon_id
             ) t ) as "pokemon",
    a.energies as "energies",
    a.name as "attackName",
    a.description as "attackDescription",
    a.damage as "attackDamage",
    pc.weakness::text || ' + 20' as "weakness",
    pc.retreat as "retreatCost",
--     array_to_string(pc.retreat, ', ') as "retreatCost2",
    d.content as "content",
    i.name as "illustrator",
    pc.rarity as "rarity"
from pokemon_card pc
left join pokemon p on pc.pokemon_id = p.id
left join description d on pc.description_id = d.id
left join attack a on pc.attack1 = a.id
left join illustrator i on pc.illustrator = i.id;

SELECT
    pc.stage as "stage",
    pc.name as "cardName",
    pc.hp as "HP",
    pc.card_type as "cardType",
    row_to_json(pokemon_data) as "pokemon",
    a.energies as "energies",
    a.name as "attackName",
    a.description as "attackDescription",
    a.damage as "attackDamage",
    pc.weakness::text || ' + 20' as "weakness",
    array_to_string(pc.retreat, ', ') as "retreatCost",
    d.content as "content",
    i.name as "illustrator",
    pc.rarity as "rarity"
FROM pokemon_card pc
LEFT JOIN description d ON pc.description_id = d.id
LEFT JOIN attack a ON pc.attack1 = a.id
LEFT JOIN illustrator i ON pc.illustrator = i.id
LEFT JOIN (
    SELECT
        id,
        lpad(cast(dex_no as text), 4, '0') as "natlNo",
        species,
        ROUND(height / 10.0, 1) as "height",
        ROUND(weight / 10.0, 1) as "weight"
    FROM pokemon
) pokemon_data ON pokemon_data.id = pc.pokemon_id;

select
    pc.name,
    pc.rarity,
    p.dex_no,
    p.species,
    round(p.height / 10.0, 1) as "height",
    round(p.weight / 10.0, 1) as "weight",
    d.content,
    e.title,
    e.series,
--     pc.card_no || bp.count
--     (select count(*) from pokemon_card pc group by pc.booster_pack_id)
    i.name,
    a.energies,
    a.name,
    a.damage,
    pc.stage,
    pc.type,
    pc.hp,
    pc.weakness,
    pc.retreat,
    e.series
from pokemon_card pc
left join pokemon p on pc.pokemon_id = p.id
left join description d on pc.description_id = d.id
left join booster_pack bp on pc.booster_pack_id = bp.id
left join expansion e on bp.expansion_id = e.id
left join attack a on pc.attack1 = a.id
left join illustrator i on i.id = pc.illustrator;

select
--     pc.name as "cardName",
    pc.rarity as "rarity",
    p.dex_no as "dexNo",
    p.species as "species",
    round(p.height / 10.0, 1) as "height",
    round(p.weight / 10.0, 1) as "weight",
    d.content as "content",
--     e.title as "expansionTitle",
--     e.series as "expansionSeries",
    pc.card_no as "cardNo",
--     i.name as "illustratorName",
    a.energies as "attackEnergies",
    a.name as "attackName",
    a.damage as "attackDamage",
    pc.stage as "stage",
    pc.type as "cardType",
    pc.hp as "hp",
    pc.weakness as "weakness",
    pc.retreat as "retreat"
--     e.series as "expansionSeries2"
from pokemon_card pc
left join pokemon p on pc.pokemon_id = p.id
left join description d on pc.description_id = d.id
-- left join booster_pack bp on pc.booster_pack_id = bp.id
-- left join expansion e on bp.expansion_id = e.id
left join attack a on pc.attack1 = a.id;
-- left join illustrator i on i.id = pc.illustrator;

select * from pokemon_card;


select * from pokemon_card;

select booster_pack_id,count(*) from pokemon_card group by booster_pack_id;


drop function insert_into_booster_pack_pokemon_card()
drop trigger before_insert_pokemon_card ON pokemon_card;