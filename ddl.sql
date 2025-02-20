create type tcg_type as enum ('grass', 'fire', 'water', 'lightning', 'psychic', 'fighting', 'darkness', 'metal', 'dragon', 'colorless');
create type vg_type as enum ('normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy', 'stellar');

drop type type;

create table pokemon_card
(
    id integer generated always as identity primary key,
    stage integer,
    ability text,
    evolves_from integer references pokemon(id), -- 화석 포켓몬 예외처리 필요
    type tcg_type not null,
    description integer references description(id), -- 1:n -> a card can have 1 description, and a description can be described in any cards(but description.pokemon_id must be equal to pokemon.id)
    pokemon_id integer references pokemon(id) not null,
    isEx boolean default false not null,
    attack1 integer references attack(id), -- n:m -> a card can have 2 attacks(moves), and an attack can be used by any pokemon
    attack2 integer references attack(id), -- n:m
    series varchar,
    rarity rarity not null,
    offer_rate numeric(2, 3) not null,
    retreat tcg_type[] not null,
    weakness tcg_type not null
);

create type rarity as enum
(
    'dia1', 'dia2', 'dia3', 'dia4', 'star1', 'star2', 'star3', 'crown1'
    -- common, uncommon, rare, double_rare, art_rare, super_rare, immserive_rare, crown_rare
);

create table trainer_card
(

);

create table item_card
(

);


create table pokemon
(
    id integer generated always as identity primary key,
    dex_no integer unique not null,
    species varchar,
    name varchar not null,
    type1 vg_type not null,
    type2 vg_type,
    height integer,
    weight integer,
    introduced_gen generation not null,
    illustrator varchar
);

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
    pokemon_id integer references pokemon(id) not null,
    generation generation
);

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
    id integer generated always as identity primary key,
    pack varchar unique not null,

)

