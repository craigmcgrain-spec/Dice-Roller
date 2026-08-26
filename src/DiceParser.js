/**
 * Parser for standard dice notation (XdY+Z)
 */
class DiceParser {
  constructor() {
    // Standard D&D dice
    this.validDice = {
      'd4': 4,
      'd6': 6,
      'd8': 8,
      'd10': 10,
      'd12': 12,
      'd20': 20,
      'd100': 100
    };
  }

  /**
   * Parse dice notation string
   * @param {string} notation - Dice notation (e.g., "3d6+2", "d20", "2d10-1")
   * @returns {Object} Parsed dice object with count, sides, modifier
   * @throws {Error} If notation is invalid
   */
  parse(notation) {
    if (typeof notation !== 'string') {
      throw new Error('Notation must be a string');
    }

    notation = notation.toLowerCase().trim();

    // Pattern: (count)d(sides)(+/- modifier)
    // count is optional (defaults to 1)
    const pattern = /^(\d*)d(\d+)([\+\-]\d+)?$/;
    const match = notation.match(pattern);

    if (!match) {
      throw new Error(`Invalid dice notation: "${notation}". Expected format like "3d6", "d20+5", or "2d10-1"`);
    }

    const count = match[1] ? parseInt(match[1]) : 1;
    const sides = parseInt(match[2]);
    const modifier = match[3] ? parseInt(match[3]) : 0;

    // Validate count
    if (count < 1) {
      throw new Error('Dice count must be at least 1');
    }
    if (count > 1000) {
      throw new Error('Dice count cannot exceed 1000');
    }

    // Validate sides (must be a standard die or any positive number)
    if (sides < 2) {
      throw new Error('Dice must have at least 2 sides');
    }
    if (sides > 10000) {
      throw new Error('Dice cannot have more than 10000 sides');
    }

    const diceType = `d${sides}`;

    return {
      notation,
      diceType,
      count,
      sides,
      modifier,
      isStandardDie: diceType in this.validDice
    };
  }

  /**
   * Check if a die type is standard D&D dice
   * @param {string} diceType - Die type (e.g., "d20")
   * @returns {boolean}
   */
  isStandardDie(diceType) {
    return diceType in this.validDice;
  }

  /**
   * Get all valid standard dice
   * @returns {Array<string>} Array of standard die types
   */
  getStandardDice() {
    return Object.keys(this.validDice).sort();
  }

  /**
   * Get sides for a standard die
   * @param {string} diceType - Die type (e.g., "d20")
   * @returns {number|null} Number of sides or null if not standard
   */
  getDiceSides(diceType) {
    return this.validDice[diceType.toLowerCase()] || null;
  }
}

module.exports = DiceParser;
