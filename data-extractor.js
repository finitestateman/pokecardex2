// 기본 정보 추출
const basicInfoTable = document.querySelector(
    'body > main > div > div > div.flex.flex-wrap.mx-auto.w-full.justify-center.pt-10.container.px-2.lg\\:px-\\[200px\\] > div.w-full.mb-6.bg-white > div.flex.flex-col.md\\:flex-row.md\\:space-x-4 > div:nth-child(3) > div > table'
);

const basicInfo = {
    name: basicInfoTable.rows[0].cells[1].textContent,
    stage: basicInfoTable.rows[1].cells[1].textContent.trim(),
    type: basicInfoTable.rows[2].cells[1].textContent.trim(),
    hp: parseInt(basicInfoTable.rows[3].cells[1].textContent),
    weakness: basicInfoTable.rows[4].cells[1].textContent.trim(),
    retreat: basicInfoTable.rows[5].cells[1].querySelectorAll('img').length,
    rarity: basicInfoTable.rows[6].cells[1].querySelector('img').alt,
    set: basicInfoTable.rows[7].cells[1].querySelector('a').textContent,
    illustrator: basicInfoTable.rows[8].cells[1].textContent,
};

// 기술 정보 추출
const moves = [];
const movesDivs = document.querySelectorAll(
    'div.border.border-black.rounded-md.px-3.pb-3.mb-5'
);

movesDivs.forEach((moveDiv) => {
    const table = moveDiv.querySelector('table');
    const move = {
        name: table.rows[0].cells[1].textContent,
        energyRequired: table.rows[1].cells[1].querySelectorAll('img').length,
        damage: parseInt(table.rows[2].cells[1].textContent) || 0,
        effect: table.rows[3]?.cells[1]?.textContent || '',
    };
    moves.push(move);
});

// 포켓몬 도감 정보 추출
const pokedexTable = document.querySelector('div:nth-child(5) table');
const pokedexInfo = {
    number: parseInt(pokedexTable.rows[0].cells[1].textContent),
    species: pokedexTable.rows[1].cells[1].textContent,
    height:
        parseFloat(
            pokedexTable.rows[2].cells[1].textContent.replace(/[^0-9.]/g, '')
        ) * 10,
    weight:
        parseFloat(
            pokedexTable.rows[3].cells[1].textContent.replace(/[^0-9.]/g, '')
        ) * 10,
    description: pokedexTable.rows[4].cells[1].textContent.trim(),
};

// 전체 데이터 객체
const cardData = {
    basicInfo,
    moves,
    pokedexInfo,
};

console.log(cardData);
