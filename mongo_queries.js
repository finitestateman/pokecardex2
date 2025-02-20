
// tcg_data 컬렉션에 원본 데이터 삽입
db.tcg_data.insertOne({
    "id": "base1-1",
    "name": "Alakazam",
    "supertype": "Pokémon",
    "subtypes": ["Stage 2"],
    "level": "42",
    "hp": "80",
    "types": ["Psychic"],
    "evolvesFrom": "Kadabra",
    "abilities": [{
        "name": "Damage Swap",
        "text": "As often as you like during your turn (before your attack), you may move 1 damage counter from 1 of your Pokémon to another as long as you don't Knock Out that Pokémon. This power can't be used if Alakazam is Asleep, Confused, or Paralyzed.",
        "type": "Pokémon Power"
    }],
    "attacks": [{
        "name": "Confuse Ray",
        "cost": ["Psychic", "Psychic", "Psychic"],
        "convertedEnergyCost": 3,
        "damage": "30",
        "text": "Flip a coin. If heads, the Defending Pokémon is now Confused."
    }],
    "weaknesses": [{
        "type": "Psychic",
        "value": "×2"
    }],
    "retreatCost": ["Colorless", "Colorless", "Colorless"],
    "convertedRetreatCost": 3,
    "number": "1",
    "artist": "Ken Sugimori", 
    "rarity": "Rare Holo",
    "flavorText": "Its brain can outperform a supercomputer. Its intelligence quotient is said to be 5000.",
    "nationalPokedexNumbers": [65],
    "legalities": {"unlimited": "Legal"},
    "images": {
        "small": "https://images.pokemontcg.io/base1/1.png",
        "large": "https://images.pokemontcg.io/base1/1_hires.png"
    }
});

// tcgdex 컬렉션에 다국어 데이터 삽입
db.tcgdex.insertOne({
    "name": {
        "en": "Alakazam",
        "fr": "Alakazam", 
        "de": "Simsala"
    },
    "illustrator": "Ken Sugimori",
    "rarity": "Rare",
    "category": "Pokemon",
    "set": "Set",
    "dexId": [65],
    "hp": 80,
    "types": ["Psychic"],
    "evolveFrom": {
        "en": "Kadabra"
    },
    "stage": "Stage2",
    "abilities": [{
        "type": "Pokemon Power",
        "name": {
            "en": "Damage Swap",
            "fr": "Transfert de dégâts",
            "de": "Schadenstausch"
        },
        "effect": {
            "en": "As often as you like during your turn (before your attack), you may move 1 damage counter from 1 of your Pokémon to another as long as you don't Knock Out that Pokémon. This power can't be used if Alakazam is Asleep, Confused, or Paralyzed.",
            "fr": "Aussi souvent que vous le souhaitez pendant votre tour (avant votre attaque), vous pouvez déplacer 1 marqueur de dégâts depuis 1 de vos Pokémon vers un autre sous réserve de ne pas mettre ce Pokémon K.O. Ce pouvoir ne peut être utilisé si Alakazam est Endormi, Confus ou Paralysé.",
            "de": "Bist Du am Zug, kannst Du (vor Deinem Angriff) beliebig oft eine Schadensmarke von einem Deiner Pokémon auf ein anderes verschieben, solange Du dieses Pokémon nicht kampfunfähig machst. Diese Fähigkeit kann nicht eingesetzt werden, falls Simsala schlafend, verwirrt oder gelähmt ist."
        }
    }],
    "retreat": 3,
    "description": {
        "en": "Its brain can outperform a supercomputer. Its intelligence quotient is said to be 5000.",
        "fr": "Son super cerveau peut effectuer des opérations plus rapidement qu'un super ordinateur. Il a un Q.I. de 5000."
    }
});

// 인덱스 생성
db.tcg_data.createIndex({ "id": 1 }, { unique: true });
db.tcg_data.createIndex({ "name": 1 });
db.tcg_data.createIndex({ "nationalPokedexNumbers": 1 });

db.tcgdex.createIndex({ "dexId": 1 });
db.tcgdex.createIndex({ "name.en": 1 });
