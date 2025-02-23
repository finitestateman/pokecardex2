"use strict";

function ownKeys(object, enumerableOnly) { var keys = Object.keys(object); if (Object.getOwnPropertySymbols) { var symbols = Object.getOwnPropertySymbols(object); if (enumerableOnly) symbols = symbols.filter(function (sym) { return Object.getOwnPropertyDescriptor(object, sym).enumerable; }); keys.push.apply(keys, symbols); } return keys; }

function _objectSpread(target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i] != null ? arguments[i] : {}; if (i % 2) { ownKeys(source, true).forEach(function (key) { _defineProperty(target, key, source[key]); }); } else if (Object.getOwnPropertyDescriptors) { Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)); } else { ownKeys(source).forEach(function (key) { Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key)); }); } } return target; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

var cheerio = require('cheerio');

var fs = require('fs').promises;

var axios = require('axios');

function extractCardData($) {
  var basicInfoTable, basicInfo, moves, pokedexTable, pokedexInfo;
  return regeneratorRuntime.async(function extractCardData$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          basicInfoTable = $('#basic-info-table');
          basicInfo = {
            name: basicInfoTable.find('tr:nth-child(1) td:nth-child(2)').text(),
            stage: basicInfoTable.find('tr:nth-child(2) td:nth-child(2)').text().trim(),
            type: basicInfoTable.find('tr:nth-child(3) td:nth-child(2)').text().trim(),
            hp: parseInt(basicInfoTable.find('tr:nth-child(4) td:nth-child(2)').text()),
            weakness: basicInfoTable.find('tr:nth-child(5) td:nth-child(2)').text().trim(),
            retreat: basicInfoTable.find('tr:nth-child(6) td:nth-child(2) img').length,
            rarity: basicInfoTable.find('tr:nth-child(7) td:nth-child(2) img').attr('alt'),
            set: basicInfoTable.find('tr:nth-child(8) td:nth-child(2) a').text(),
            illustrator: basicInfoTable.find('tr:nth-child(9) td:nth-child(2)').text()
          };
          moves = [];
          $('.moves-div').each(function (_, moveDiv) {
            var moveTable = $(moveDiv).find('table');
            var move = {
              name: moveTable.find('tr:nth-child(1) td:nth-child(2)').text(),
              energyRequired: moveTable.find('tr:nth-child(2) td:nth-child(2) img').length,
              damage: parseInt(moveTable.find('tr:nth-child(3) td:nth-child(2)').text()) || 0,
              effect: moveTable.find('tr:nth-child(4) td:nth-child(2)').text() || ''
            };
            moves.push(move);
          });
          pokedexTable = $('#pokedex-table');
          pokedexInfo = {
            number: parseInt(pokedexTable.find('tr:nth-child(1) td:nth-child(2)').text()),
            species: pokedexTable.find('tr:nth-child(2) td:nth-child(2)').text(),
            height: parseFloat(pokedexTable.find('tr:nth-child(3) td:nth-child(2)').text().replace(/[^0-9.]/g, '')) * 10,
            weight: parseFloat(pokedexTable.find('tr:nth-child(4) td:nth-child(2)').text().replace(/[^0-9.]/g, '')) * 10,
            description: pokedexTable.find('tr:nth-child(5) td:nth-child(2)').text().trim()
          };
          return _context.abrupt("return", {
            basicInfo: basicInfo,
            moves: moves,
            pokedexInfo: pokedexInfo
          });

        case 7:
        case "end":
          return _context.stop();
      }
    }
  });
}

function scrapeCards() {
  var allCards, errors, i, url, response, $, cardData;
  return regeneratorRuntime.async(function scrapeCards$(_context2) {
    while (1) {
      switch (_context2.prev = _context2.next) {
        case 0:
          allCards = [];
          errors = [];
          i = 1;

        case 3:
          if (!(i <= 215)) {
            _context2.next = 26;
            break;
          }

          _context2.prev = 4;
          console.log("Scraping card ".concat(i, "/215..."));
          url = "https://gamevlg.com/pokemon-tcg-pocket/cards/".concat(i);
          _context2.next = 9;
          return regeneratorRuntime.awrap(axios.get(url));

        case 9:
          response = _context2.sent;
          $ = cheerio.load(response.data);
          _context2.next = 13;
          return regeneratorRuntime.awrap(extractCardData($));

        case 13:
          cardData = _context2.sent;
          allCards.push(_objectSpread({
            id: i
          }, cardData)); // 요청 간 간격 추가 (서버 부하 방지)

          _context2.next = 17;
          return regeneratorRuntime.awrap(new Promise(function (resolve) {
            return setTimeout(resolve, 1000);
          }));

        case 17:
          _context2.next = 23;
          break;

        case 19:
          _context2.prev = 19;
          _context2.t0 = _context2["catch"](4);
          console.error("Error scraping card ".concat(i, ":"), _context2.t0.message);
          errors.push({
            id: i,
            error: _context2.t0.message
          });

        case 23:
          i++;
          _context2.next = 3;
          break;

        case 26:
          _context2.next = 28;
          return regeneratorRuntime.awrap(fs.writeFile('cards.json', JSON.stringify(allCards, null, 2)));

        case 28:
          if (!(errors.length > 0)) {
            _context2.next = 31;
            break;
          }

          _context2.next = 31;
          return regeneratorRuntime.awrap(fs.writeFile('errors.json', JSON.stringify(errors, null, 2)));

        case 31:
          console.log("Scraping completed! Total cards: ".concat(allCards.length));

          if (errors.length > 0) {
            console.log("Errors encountered: ".concat(errors.length));
          }

        case 33:
        case "end":
          return _context2.stop();
      }
    }
  }, null, null, [[4, 19]]);
}

scrapeCards()["catch"](console.error);
//# sourceMappingURL=card-scraper.dev.js.map
