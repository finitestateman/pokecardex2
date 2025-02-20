const cheerio = require('cheerio');
const fs = require('fs').promises;
const axios = require('axios');

async function extractCardData($) {
    const basicInfoTable = $('#basic-info-table');
    const basicInfo = {
        name: basicInfoTable.find('tr:nth-child(1) td:nth-child(2)').text(),
        stage: basicInfoTable
            .find('tr:nth-child(2) td:nth-child(2)')
            .text()
            .trim(),
        type: basicInfoTable
            .find('tr:nth-child(3) td:nth-child(2)')
            .text()
            .trim(),
        hp: parseInt(
            basicInfoTable.find('tr:nth-child(4) td:nth-child(2)').text()
        ),
        weakness: basicInfoTable
            .find('tr:nth-child(5) td:nth-child(2)')
            .text()
            .trim(),
        retreat: basicInfoTable.find('tr:nth-child(6) td:nth-child(2) img')
            .length,
        rarity: basicInfoTable
            .find('tr:nth-child(7) td:nth-child(2) img')
            .attr('alt'),
        set: basicInfoTable.find('tr:nth-child(8) td:nth-child(2) a').text(),
        illustrator: basicInfoTable
            .find('tr:nth-child(9) td:nth-child(2)')
            .text(),
    };

    const moves = [];
    $('.moves-div').each((_, moveDiv) => {
        const moveTable = $(moveDiv).find('table');
        const move = {
            name: moveTable.find('tr:nth-child(1) td:nth-child(2)').text(),
            energyRequired: moveTable.find(
                'tr:nth-child(2) td:nth-child(2) img'
            ).length,
            damage:
                parseInt(
                    moveTable.find('tr:nth-child(3) td:nth-child(2)').text()
                ) || 0,
            effect:
                moveTable.find('tr:nth-child(4) td:nth-child(2)').text() || '',
        };
        moves.push(move);
    });

    const pokedexTable = $('#pokedex-table');
    const pokedexInfo = {
        number: parseInt(
            pokedexTable.find('tr:nth-child(1) td:nth-child(2)').text()
        ),
        species: pokedexTable.find('tr:nth-child(2) td:nth-child(2)').text(),
        height:
            parseFloat(
                pokedexTable
                    .find('tr:nth-child(3) td:nth-child(2)')
                    .text()
                    .replace(/[^0-9.]/g, '')
            ) * 10,
        weight:
            parseFloat(
                pokedexTable
                    .find('tr:nth-child(4) td:nth-child(2)')
                    .text()
                    .replace(/[^0-9.]/g, '')
            ) * 10,
        description: pokedexTable
            .find('tr:nth-child(5) td:nth-child(2)')
            .text()
            .trim(),
    };

    return {
        basicInfo,
        moves,
        pokedexInfo,
    };
}

async function scrapeCards() {
    const allCards = [];
    const errors = [];

    for (let i = 1; i <= 215; i++) {
        try {
            console.log(`Scraping card ${i}/215...`);
            const url = `https://gamevlg.com/pokemon-tcg-pocket/cards/${i}`;
            const response = await axios.get(url);
            const $ = cheerio.load(response.data);
            const cardData = await extractCardData($);
            allCards.push({ id: i, ...cardData });

            // 요청 간 간격 추가 (서버 부하 방지)
            await new Promise((resolve) => setTimeout(resolve, 1000));
        } catch (error) {
            console.error(`Error scraping card ${i}:`, error.message);
            errors.push({ id: i, error: error.message });
        }
    }

    // 결과 저장
    await fs.writeFile('cards.json', JSON.stringify(allCards, null, 2));
    if (errors.length > 0) {
        await fs.writeFile('errors.json', JSON.stringify(errors, null, 2));
    }

    console.log(`Scraping completed! Total cards: ${allCards.length}`);
    if (errors.length > 0) {
        console.log(`Errors encountered: ${errors.length}`);
    }
}

scrapeCards().catch(console.error);
