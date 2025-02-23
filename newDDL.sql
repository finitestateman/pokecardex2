-- enums
create type tcg_type as enum ('grass', 'fire', 'water', 'lightning', 'psychic', 'fighting', 'darkness', 'metal', 'dragon', 'colorless');
create type rpg_type as enum ('normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy', 'stellar');
create type trainer as enum ('item', 'pokemon_tool', 'fossil', 'supporter');
-- alter type vg_type rename to rpg_type;
create type rarity as enum ( 'd1', 'd2', 'd3', 'd4', 's1', 's2', 's3', 'c');
-- promo -- common, uncommon, rare, double_rare, art_rare, super_rare, immserive_rare, crown_rare

create type operator as enum ('+', '*');

-- domains
create domain generation as integer check (value between 1 and 9);
create domain stage as integer check (value in (0, 1, 2));

-- tables
create table pokemon
(
    id             uuid default gen_random_uuid() primary key,
    dex_no         integer  not null, -- 전국 도감 번호(0025)
    species        varchar  not null, -- 'Mouse Pokémon'
    name           varchar  not null, -- 'Pikachu'
    type1          rpg_type not null, -- 'electric'::lightning
    type2          rpg_type,          -- 두번째 타입은 없을 수도 있다
    height         integer,           -- 40(cm)
    weight         integer,           -- 6000(g)
    introduced_gen generation,
    unique (dex_no, name)
);
-- 1:n -> 한 포켓몬은 여러 포켓몬 카드에 속할 수 있음

create table description
(
    id         integer generated always as identity primary key,
    content    text                                                              not null,
    pokemon_id uuid references pokemon (id) on delete set null on update cascade not null unique
);

create table illustrator
(
    id   integer generated always as identity primary key,
    name varchar unique not null
);

create table attack
(
    id          integer generated always as identity primary key,
    name        varchar unique not null, -- 'Thunderbolt'
    damage      integer        not null, -- 140
    energies    tcg_type[]     not null, -- ['lightning'::tcg_type, 'lightning'::tcp_type, 'lightning'::tcg_type]
    description text,                    -- 'Discard all Energy from this Pokémon.'
    operator    operator
);

create table expansion
(
    id         integer primary key,
    title      varchar     not null, -- 'Genetic Apex'
    alias      varchar     not null, -- 'PROMO-A', 'A1', 'A1a', 'A2'
    series     varchar,              -- 'A'
    code       varchar     not null, -- 'P-A', 'A1', 'A1a', 'A2'
    releasedAt timestamptz not null
);
-- PROMO-A는 아이디를 0으로 한다
-- 1:n -> 한 확장팩은 여러 부스터팩을 가질 수 있음

create table booster_pack
(
    id           integer primary key,
    expansion_id integer references expansion (id) not null, -- n:1 -> 여러 부스터팩이 한 확장팩에 속함
    name         varchar                           not null, -- 'Mewtwo', 'Pikachu', 'Charizard'
    count        integer                           not null  -- 동적으로 계산하지 말고 트리거로 미리 계산된 값을 사용
);

create table ability
(
    id          integer generated always as identity primary key,
    name        varchar unique not null, -- 'Shell Armor'
    description text                     -- 'This Pokémon takes -10 damage from attacks.'
);


create table pokemon_card
(
    id             uuid default gen_random_uuid() primary key,
    name           varchar                        not null, -- 'Raichu', 'Pikachu ex'
    card_no        integer unique                 not null, -- 0026 카드가 속한 부스터팩 내부에서의 번호
    stage          stage                          not null, -- 0, 1, 2 진화 상태('Basic', 'Stage 1', 'Stage 2') 대신 숫자로 사용
    hp             integer                        not null, -- 120
    type           tcg_type                       not null, -- 'lightning'::tcg_type
    attack1        integer references attack (id) not null, -- n:1 -> 여러 포켓몬 카드가 하나의 첫번째 공격 기술을 참조함
    attack2        integer refrernces attack (id),          -- n:1 -> 여러 포켓몬 카드가 하나의 두번째 공격 기술을 참조할 수 있음(nullable)
    rarity         rarity                         not null,
    retreat        tcg_type[]                     not null, -- ['colorless'::tcg_type, 'colorless'::tcg_type]
    weakness       tcg_type                       not null,
    illustrator_id integer references illustrator (id),
    ex_rule        text,                                    -- 'When your Pokémon ex is Knocked Out, your opponents gets 2 points.' 이 값이 존재하면 ex pokemon이므로 boolean처럼 사용. ex_text 값은 항상 같은 것 같다
    -- n:1 -> 여러 포켓몬 카드가 한 포켓몬으로부터 진화할 수 있음, 화석 포켓몬에 대한 예외처리 필요
    -- pokemon_id 참조하는 원리와 같음
    evolves_from   uuid references pokemon (id),
    ability_id     integer references ability (id),
    pokemon_id     uuid references pokemon (id)   not null, -- n:1 -> 여러 포켓몬 카드가 하나의 포켓몬을 참조할 수 있음
    description_id integer references description (id)
);

create table meta_card_info
(
    id integer generated always as identity primary key,
    pokemon_card_id    uuid references pokemon_card (id) on delete cascade,
    trainer_card_id    uuid references trainer_card (id) on delete cascade,
    point integer,
    offering_rate numeric(6, 3),
    unique (pokemon_card_id, trainer_card_id)
);

create table booster_pack_pokemon_card
(
    booster_pack_id integer references booster_pack (id)      not null,
    pokemon_card_id uuid references pokemon_card (id)         not null,
    card_no         integer references pokemon_card (card_no) not null,
    primary key (booster_pack_id, pokemon_card_id),
    unique (booster_pack_id, card_no)
);

create table trainer_card
(
    id             uuid default gen_random_uuid() primary key,
    kind           trainer        not null,
    name           varchar unique not null,
    description    text           not null,
    rarity         rarity,
    footnote       text,
    illustrator_id integer references illustrator (id)
);

create table fossil_card
(
    trainer_card_id uuid primary key references trainer_card (id) on delete cascade,
    hp              integer not null
);

create table promo_card
(
    id              integer generated always as identity primary key,
    pokemon_card_id uuid references pokemon_card (id) on delete cascade,
    trainer_card_id uuid references trainer_card (id) on delete cascade,
    how_to_obtain   text,
    unique (pokemon_card_id, trainer_card_id)
);


-- dml

-- insert
insert into pokemon(dex_no, species, name, type1, type2, height, weight, introduced_gen)
values (1, 'Seed Pokémon', 'Bulbasaur', 'grass'::rpg_type, 'poison'::rpg_type, 7, 69, 1),
       (2, 'Seed Pokémon', 'Ivysaur', 'grass'::rpg_type, 'poison'::rpg_type, 10, 130, 1),
       (3, 'Seed Pokémon', 'Venusaur', 'grass'::rpg_type, 'poison'::rpg_type, 20, 1000, 1),
       (4, 'Lizard Pokémon', 'Charmander', 'fire'::rpg_type, null, 6, 85, 1),
       (5, 'Flame Pokémon', 'Charmeleon', 'fire'::rpg_type, null, 11, 190, 1),
       (6, 'Flame Pokémon', 'Charizard', 'fire'::rpg_type, 'flying'::rpg_type, 17, 905, 1),
       (7, 'Tiny Turtle Pokémon', 'Squirtle', 'water'::rpg_type, null, 5, 90, 1),
       (8, 'Turtle Pokémon', 'Wartortle', 'water'::rpg_type, null, 10, 225, 1),
       (9, 'Shellfish Pokémon', 'Blastoise', 'water'::rpg_type, null, 16, 855, 1);

INSERT INTO description (content, pokemon_id)
VALUES ('There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger.',
        (SELECT id FROM pokemon WHERE dex_no = 1)),
       ('When the bulb on its back grows large, it appears to lose the ability to stand on its hind legs.',
        (SELECT id FROM pokemon WHERE dex_no = 2)),
       ('Its plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight.',
        (SELECT id FROM pokemon WHERE dex_no = 3)),
       ('It has a preference for hot things. When it rains, steam is said to spout from the tip of its tail.',
        (SELECT id FROM pokemon WHERE dex_no = 4)),
       ('It has a barbaric nature. In battle, it whips its fiery tail around and slashed away with sharp claws',
        (SELECT id FROM pokemon WHERE dex_no = 5)),
       ('It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.',
        (SELECT id FROM pokemon WHERE dex_no = 6)),
       ('When it retracts its long neck into its shell, it squirts out water with vigorous force.',
        (SELECT id FROM pokemon WHERE dex_no = 7)),
       ('It is recognized as a symbol of longevity. If its shell has algae on it, that Wartortle is very old',
        (SELECT id FROM pokemon WHERE dex_no = 8)),
       ('It crushes its foe under its heavy body to cause fainting. In a pinch, it will withdraw inside its shell',
        (SELECT id FROM pokemon WHERE dex_no = 9));

insert into illustrator(name)
values ('Narumi Sato'),
       ('Teeziro'),
       ('Mizue'),
       ('Kurata So'),
       ('Ryota Murayama'),
       ('kantaro'),
       ('takuyoa'),
       ('PLANETA CG Works'),
       ('PLANETA Mochizuki'),
       ('Nelnal'),
       ('Nurikabe'),
       ('PLANETA Tsuji'),
       ('Mitsuhiro Arita'),
       ('AKIRA EGAWA')
on conflict do nothing;
select * from illustrator;

insert into attack (name, damage, energies, description, operator)
values ('Vine Whip', 40, ARRAY ['grass'::tcg_type, 'colorless'::tcg_type], null, null),
       ('Razor Leaf', 60, ARRAY ['grass'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], null, null),
       ('Mega Drain', 80, ARRAY ['grass'::tcg_type, 'grass'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type],
        'Heal 30 damage from this Pokémon.', null),
       ('Giant Bloom', 100, ARRAY ['grass'::tcg_type, 'grass'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'Heal 30 damage from this Pokémon.', null),
       ('Ember', 30, ARRAY ['fire'::tcg_type], 'Discard a [fire] Energy from this Pokémon.', null),
       ('Fire Claws', 60, ARRAY ['fire'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], null, null),
       ('Fire Spin', 150, ARRAY ['fire'::tcg_type, 'fire'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type],
        null, null),
       ('Slash', 60, ARRAY ['fire'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], null, null),
       ('Crimson Storm', 200, ARRAY ['fire'::tcg_type, 'fire'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'Discard 2 [fire] Energy from this Pokémon.', null),
       ('Water Gun', 20, ARRAY ['water'::tcg_type], null, null),
       ('Wave Splash', 40, ARRAY ['water'::tcg_type, 'colorless'::tcg_type], null, null),
       ('Hydro Pump', 80, ARRAY ['water'::tcg_type, 'water'::tcg_type, 'colorless'::tcg_type],
        'If this Pokémon has at least 2 extra [water] Energy attached, this attack does 60 more damage.', '+'),
       ('Surf', 40, ARRAY ['water'::tcg_type, 'colorless'::tcg_type], null, null),
       ('Hydro Bazooka', 100, ARRAY['water'::tcg_type, 'water'::tcg_type, 'colorless'::tcg_type], 'If this Pokémon has at least 2 extra [water] Energy attached, this attack does 60 more damage.', '+')

on conflict  do nothing ;
select * from attack;

INSERT INTO expansion (id, title, series, alias, code, releasedAt)
VALUES (0, 'PROMO-A', 'A', 'PROMO-A', 'P-A', '2024-10-30 00:00:00 UTC'::timestamptz),
       (1, 'Genetic Apex', 'A', 'A1', 'A1', '2024-10-30 00:00:00 UTC'::timestamptz),
       (2, 'Mythical Island', 'A', 'A1a', 'A1a', '2024-12-17 00:00:00 UTC'::timestamptz),
       (3, 'Space-Time Smackdown', 'A', 'A2', 'A2', '2025-01-30 00:00:00 UTC'::timestamptz);

insert into booster_pack (id, expansion_id, name, count)
values (1, 1, 'Mewtwo', 0),
       (2, 1, 'Pikachu', 0),
       (3, 1, 'Charizard', 0),
       (4, 2, 'Themed Booster Pack', 0),
       (5, 3, 'Diala', 0),
       (6, 3, 'Palkia', 0);

insert into ability (name, description)
values ('Powder Heal', 'Once during your turn you may heal 20 damage from each of your Pokémon.'),
       ('Fragrance Trap', 'If this Pokémon is in the Active Spot, once during your turn, you may switch in 1 of your opponent''s Benched Basic Pokémon to the Active Spot.'),
       ('Counterattack', 'If this Pokémon is in the Active Spot and is damaged by an attack from your opponent''s Pokémon, do 20 damage to the Attacking Pokémon.'),
       ('Shell Armor', 'This Pokémon takes -10 damage from attacks.'),
       ('Water Shuriken', 'Once during your turn, you may do 20 damage to 1 of your opponent''s Pokémon,');

insert into pokemon_card (name, card_no, stage, hp, type, attack1, attack2, rarity, retreat, weakness, illustrator_id, ex_rule, evolves_from, ability_id, pokemon_id, description_id)
values ('Bulbasaur', 1, 0, 70, 'grass'::tcg_type, (select id from attack where name = 'Vine Whip'), null, 'd1', ARRAY['colorless'::tcg_type], 'fire'::tcg_type, (select id from illustrator where name like '%Sato%'), null, null, null, (select id from pokemon where name = 'Bulbasaur'), 19),
       ('Ivysaur', 2, 1, 90, 'grass'::tcg_type, (select id from attack where name = 'Razor Leaf'), null, 'd2', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type], 'fire'::tcg_type, (select id from illustrator where name like '%Kurata%'), null, (SELECT id from pokemon where name = 'Bulbasaur'), null, (select id from pokemon where name = 'Ivysaur'), 20),
       ('Venusaur', 3, 2, 160, 'grass'::tcg_type, (select id from attack where name = 'Mega Drain'), null, 'd3', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'fire'::tcg_type, (select id from illustrator where name like '%Ryota%'), null, (select id from pokemon where name = 'Ivysaur'), null, (select id from pokemon where name = 'Venusaur'), 21),
       ('Venusaur ex', 4, 2, 190, 'grass'::tcg_type, (select id from attack where name = 'Razor Leaf'), (select id from attack where name = 'Giant Bloom'), 'd4', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'fire'::tcg_type, (select id from illustrator where name like '%CG Works%'), '1', (select id from pokemon where name = 'Ivysaur'), null, (select id from pokemon where name = 'Venusaur'), null),
       ('Charmander', 33, 0, 60, 'fire'::tcg_type, (select id from attack where name = 'Ember'), null, 'd1', ARRAY['colorless'::tcg_type], 'water'::tcg_type, (select id from illustrator where name like 'Teeziro'), null, null, null, (select id from pokemon where name = 'Charmander'), 22),
       ('Charmeleon', 34, 1, 90, 'fire'::tcg_type, (select id from attack where name = 'Fire Claws'), null, 'd2', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type], 'water'::tcg_type, (select id from illustrator where name like 'kantaro'), null, (select id from pokemon where name = 'Charmander'), null, (select id from pokemon where name = 'Charmeleon'), 23),
       ('Charizard', 35, 2, 150, 'fire'::tcg_type, (select id from attack where name = 'Fire Spin'), null, 'd3', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type], 'water'::tcg_type, (select id from illustrator where name like 'takuyoa'), null, (select id from pokemon where name = 'Charmeleon'), null, (select id from pokemon where name = 'Charizard'), 24),
       ('Charizard ex', 36, 2, 180, 'fire'::tcg_type, (select id from attack where name = 'Slash'), (select id from attack where name = 'Crimson Storm'), 'd4', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type], 'water'::tcg_type, (select id from illustrator where name like '%Mochizuki%'), '1', (select id from pokemon where name = 'Charmeleon'), null, (select id from pokemon where name = 'Charizard'), null),
       ('Squirtle', 53, 0, 60, 'water'::tcg_type, (select id from attack where name = 'Water Gun'), null, 'd1', ARRAY['colorless'::tcg_type], 'lightning'::tcg_type, (select id from illustrator where name like 'Mizue'), null, null, null, (select id from pokemon where name = 'Squirtle'), 25),
       ('Wartortle', 54, 1, 80, 'water'::tcg_type, (select id from attack where name = 'Wave Splash'), null, 'd2', ARRAY['colorless'::tcg_type], 'lightning'::tcg_type, (select id from illustrator where name like 'Nelnal'), null, (select id from pokemon where name = 'Squirtle'), null, (select id from pokemon where name = 'Wartortle'), 26),
       ('Blastoise', 55, 2, 150, 'water'::tcg_type, (select id from attack where name = 'Hydro Pump'), null, 'd3', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'lightning'::tcg_type, (select id from illustrator where name like 'Nurikabe'), null, (select id from pokemon where name = 'Wartortle'), null, (select id from pokemon where name = 'Blastoise'), 27),
       ('Blastoise ex', 56, 2, 180, 'water'::tcg_type, (select id from attack where name = 'Surf'), (select id from attack where name = 'Hydro Bazooka'), 'd4', ARRAY['colorless'::tcg_type, 'colorless'::tcg_type, 'colorless'::tcg_type], 'lightning'::tcg_type, (select id from illustrator where name like '%Tsuji'), '1', (select id from pokemon where name = 'Wartortle'), null, (select id from pokemon where name = 'Blastoise'), null)
on conflict do nothing ;

select * from pokemon_card order by card_no;


select * from booster_pack;

insert into booster_pack_pokemon_card (booster_pack_id, pokemon_card_id, card_no)
values ((SELECT id from booster_pack where name = 'Mewtwo'), (select id from pokemon_card where name = 'Bulbasaur'), 1);
select * from booster_pack_pokemon_card;

select * from booster_pack_pokemon_card bppc
         left join pokemon_card pc on pc.card_no = bppc.card_no
         left join booster_pack bp on bppc.booster_pack_id = bp.id
where pc.name = 'Bulbasaur';
