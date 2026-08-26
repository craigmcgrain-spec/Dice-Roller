/**
 * Represents the result of a dice roll
 */
class RollResult {
  constructor(data) {
    this.notation = data.notation;
    this.diceType = data.diceType;
    this.diceCount = data.diceCount;
    this.diceSides = data.diceSides;
    this.rolls = data.rolls;
    this.subtotal = data.subtotal;
    this.modifier = data.modifier;
    this.total = data.total;
    this.isCritical = data.isCritical;
    this.timestamp = data.timestamp;
  }

  /**
   * Get critical message for d20 rolls
   * @returns {string|null} Critical message or null
   */
  getCriticalMessage() {
    if (!this.isCritical) return null;

    if (this.isCritical.type === 'critical_success') {
      return "You're a Natural";
    } else if (this.isCritical.type === 'critical_failure') {
      return "You're Fucked";
    }
    return null;
  }

  /**
   * Get a formatted string representation of the roll
   * @returns {string}
   */
  toString() {
    let result = `${this.notation}: `;
    result += `[${this.rolls.join(', ')}]`;
    
    if (this.modifier !== 0) {
      result += ` ${this.modifier > 0 ? '+' : ''}${this.modifier}`;
    }
    
    result += ` = ${this.total}`;

    const critMessage = this.getCriticalMessage();
    if (critMessage) {
      result += ` [${critMessage}]`;
    }

    return result;
  }

  /**
   * Get a detailed object representation
   * @returns {Object}
   */
  toJSON() {
    return {
      notation: this.notation,
      diceType: this.diceType,
      diceCount: this.diceCount,
      diceSides: this.diceSides,
      rolls: this.rolls,
      subtotal: this.subtotal,
      modifier: this.modifier,
      total: this.total,
      critical: this.isCritical,
      criticalMessage: this.getCriticalMessage(),
      timestamp: this.timestamp.toISOString()
    };
  }

  /**
   * Get a simple result (just the total)
   * @returns {number}
   */
  valueOf() {
    return this.total;
  }
}

module.exports = RollResult;
