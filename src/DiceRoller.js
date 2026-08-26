const DiceParser = require('./DiceParser');
const RollResult = require('./RollResult');

/**
 * Main DiceRoller class for managing dice rolls and history
 */
class DiceRoller {
  constructor() {
    this.history = [];
    this.parser = new DiceParser();
  }

  /**
   * Roll dice according to given notation
   * @param {string} notation - Dice notation (e.g., "3d6", "2d20+5")
   * @returns {Object} Roll result object
   */
  roll(notation) {
    const parsed = this.parser.parse(notation);
    const result = this._executeRoll(parsed);
    this.history.push({
      notation,
      result,
      timestamp: new Date()
    });
    return result;
  }

  /**
   * Roll multiple different dice sets
   * @param {Array<string>} notations - Array of notation strings
   * @returns {Array<Object>} Array of roll results
   */
  rollMultiple(notations) {
    if (!Array.isArray(notations)) {
      throw new Error('rollMultiple expects an array of notation strings');
    }
    return notations.map(notation => this.roll(notation));
  }

  /**
   * Execute a parsed roll and return results
   * @private
   * @param {Object} parsed - Parsed dice notation
   * @returns {RollResult} Result object
   */
  _executeRoll(parsed) {
    const rolls = [];
    
    for (let i = 0; i < parsed.count; i++) {
      rolls.push(this._rollSingleDie(parsed.sides));
    }

    const subtotal = rolls.reduce((sum, roll) => sum + roll, 0);
    const total = subtotal + parsed.modifier;

    return new RollResult({
      notation: parsed.notation,
      diceType: parsed.diceType,
      diceCount: parsed.count,
      diceSides: parsed.sides,
      rolls,
      subtotal,
      modifier: parsed.modifier,
      total,
      isCritical: this._checkCritical(parsed.diceType, rolls),
      timestamp: new Date()
    });
  }

  /**
   * Roll a single die
   * @private
   * @param {number} sides - Number of sides on the die
   * @returns {number} Roll result (1 to sides)
   */
  _rollSingleDie(sides) {
    return Math.floor(Math.random() * sides) + 1;
  }

  /**
   * Check if roll contains critical results (nat 1 or nat 20 on d20)
   * @private
   * @param {string} diceType - Type of die (e.g., "d20")
   * @param {Array<number>} rolls - Array of individual roll results
   * @returns {Object|null} Critical result info or null
   */
  _checkCritical(diceType, rolls) {
    if (diceType !== 'd20') return null;

    const nat20s = rolls.filter(r => r === 20);
    const nat1s = rolls.filter(r => r === 1);

    if (nat20s.length > 0) {
      return { type: 'critical_success', count: nat20s.length };
    }
    if (nat1s.length > 0) {
      return { type: 'critical_failure', count: nat1s.length };
    }
    return null;
  }

  /**
   * Get roll history
   * @param {number} limit - Maximum number of rolls to return (default: 10)
   * @returns {Array<Object>} Array of historical rolls
   */
  getHistory(limit = 10) {
    return this.history.slice(-limit);
  }

  /**
   * Get full roll history
   * @returns {Array<Object>} Complete roll history
   */
  getFullHistory() {
    return [...this.history];
  }

  /**
   * Clear roll history
   */
  clearHistory() {
    this.history = [];
  }

  /**
   * Get statistics from multiple rolls
   * @param {string} notation - Dice notation to roll
   * @param {number} count - Number of times to roll
   * @returns {Object} Statistics object with min, max, average, etc.
   */
  getStatistics(notation, count = 100) {
    if (typeof notation === 'number') {
      // Handle legacy usage: getStatistics(count) for 1d20
      count = notation;
      notation = '1d20';
    }

    const results = [];
    const currentHistoryLength = this.history.length;

    for (let i = 0; i < count; i++) {
      const result = this.roll(notation);
      results.push(result.total);
    }

    const sorted = [...results].sort((a, b) => a - b);
    const sum = results.reduce((a, b) => a + b, 0);
    const average = sum / count;
    const variance = results.reduce((sum, val) => sum + Math.pow(val - average, 2), 0) / count;
    const stdDev = Math.sqrt(variance);
    const median = count % 2 === 0 
      ? (sorted[count / 2 - 1] + sorted[count / 2]) / 2 
      : sorted[Math.floor(count / 2)];

    // Remove the stats rolls from history, keeping only original history
    this.history = this.history.slice(0, currentHistoryLength);

    return {
      notation,
      samples: count,
      min: sorted[0],
      max: sorted[count - 1],
      average: Math.round(average * 100) / 100,
      median,
      stdDev: Math.round(stdDev * 100) / 100,
      mode: this._calculateMode(results),
      distribution: this._calculateDistribution(results)
    };
  }

  /**
   * Calculate the mode (most common value) from results
   * @private
   * @param {Array<number>} results - Array of roll totals
   * @returns {number} The most common value
   */
  _calculateMode(results) {
    const frequency = {};
    let maxFreq = 0;
    let mode = results[0];

    results.forEach(val => {
      frequency[val] = (frequency[val] || 0) + 1;
      if (frequency[val] > maxFreq) {
        maxFreq = frequency[val];
        mode = val;
      }
    });

    return mode;
  }

  /**
   * Calculate distribution of results
   * @private
   * @param {Array<number>} results - Array of roll totals
   * @returns {Object} Distribution map
   */
  _calculateDistribution(results) {
    const distribution = {};
    results.forEach(val => {
      distribution[val] = (distribution[val] || 0) + 1;
    });
    return distribution;
  }
}

module.exports = DiceRoller;
