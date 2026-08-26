/**
 * D&D-specific scenarios using the Dice Roller plugin
 */

const DiceRoller = require('../src/index');

const roller = new DiceRoller();

console.log('=== D&D SCENARIOS ===\n');

// Scenario 1: Attack roll with advantage
console.log('SCENARIO 1: Attack roll with advantage');
console.log('You have advantage on your attack roll!\n');
const advRoll1 = roller.roll('d20');
const advRoll2 = roller.roll('d20');
const advantage = Math.max(advRoll1.total, advRoll2.total);
const modifier = 5;
const attackTotal = advantage + modifier;
console.log(`  Roll 1: ${advRoll1.total}`);
console.log(`  Roll 2: ${advRoll2.total}`);
console.log(`  Advantage (take higher): ${advantage}`);
console.log(`  With +${modifier} modifier: ${attackTotal}`);
console.log(`  ${attackTotal >= 10 ? 'HIT!' : 'MISS!'}\n`);

// Scenario 2: Multi-attack turn
console.log('SCENARIO 2: Fighter\'s turn - Multiple attacks');
console.log('You attack with sword (1d8+3) and bonus action dagger (1d4+2)\n');
const swordDamage = roller.roll('1d8+3');
const daggerDamage = roller.roll('1d4+2');
console.log(`  Sword damage: ${swordDamage.toString()}`);
console.log(`  Dagger damage: ${daggerDamage.toString()}`);
console.log(`  Total damage: ${swordDamage.total + daggerDamage.total}\n`);

// Scenario 3: Saving throw
console.log('SCENARIO 3: Dodging a fireball - Dex saving throw');
console.log('You need to roll a Dex save (DC 15) against a fireball spell\n');
const savingThrow = roller.roll('d20+4');
const dc = 15;
console.log(`  Roll: ${savingThrow.toString()}`);
if (savingThrow.total >= dc) {
  console.log(`  ✓ SAVE SUCCEEDED! You take half damage!\n`);
} else {
  console.log(`  ✗ SAVE FAILED! You take full damage!\n`);
}

// Scenario 4: Spell damage - fireball
console.log('SCENARIO 4: Casting fireball spell');
console.log('Your fireball hits 3 targets!\n');
const targets = 3;
const fireballDamage = roller.rollMultiple(
  Array(targets).fill('8d6')
);
fireballDamage.forEach((damage, i) => {
  console.log(`  Target ${i + 1}: ${damage.toString()}`);
});
const totalDamage = fireballDamage.reduce((sum, d) => sum + d.total, 0);
console.log(`  Total damage across all targets: ${totalDamage}\n`);

// Scenario 5: Critical hit!
console.log('SCENARIO 5: CRITICAL HIT!');
console.log('You rolled a natural 20!\n');
const normalDamage = roller.roll('1d10+3');
const critDamage = roller.roll('2d10+3');
console.log(`  Normal hit would deal: ${normalDamage.toString()}`);
console.log(`  Critical hit deals (double dice): ${critDamage.toString()}\n`);

// Scenario 6: Healing
console.log('SCENARIO 6: Casting cure wounds');
console.log('You cast cure wounds to heal an ally\n');
const healing = roller.roll('1d8+3');
console.log(`  Healing amount: ${healing.total}\n`);

// Scenario 7: Long rest hit point recovery
console.log('SCENARIO 7: Long rest - recover hit points');
console.log('You rest for the night and roll to recover HP\n');
const classHitDie = 'd10'; // Fighter
const hitDieCount = 2;
const recoveryRolls = roller.rollMultiple(
  Array(hitDieCount).fill(classHitDie)
);
const recoveredHP = recoveryRolls.reduce((sum, roll) => sum + roll.total, 0);
console.log(`  Hit die: ${classHitDie}`);
console.log(`  Rolls: ${recoveryRolls.map(r => r.total).join(' + ')}`);
console.log(`  Hit points recovered: ${recoveredHP}\n`);

// Scenario 8: Ability score generation
console.log('SCENARIO 8: Generating ability scores (4d6 drop lowest)');
const abilities = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
const scores = {};

abilities.forEach(ability => {
  const rolls = [
    roller.roll('1d6'),
    roller.roll('1d6'),
    roller.roll('1d6'),
    roller.roll('1d6')
  ];
  const sorted = rolls.map(r => r.total).sort((a, b) => b - a);
  const dropped = sorted[3];
  const score = sorted.slice(0, 3).reduce((a, b) => a + b, 0);
  scores[ability] = score;
  console.log(`  ${ability}: [${rolls.map(r => r.total).join(', ')}] → drop ${dropped} = ${score}`);
});
console.log();

// Scenario 9: Skill check
console.log('SCENARIO 9: Stealth check');
console.log('You attempt to sneak past a guard\n');
const stealthBonus = 5;
const stealthCheck = roller.roll('d20');
const difficulty = 13;
const stealthTotal = stealthCheck.total + stealthBonus;
console.log(`  Roll: ${stealthCheck.total}`);
console.log(`  Bonus: +${stealthBonus}`);
console.log(`  Total: ${stealthTotal}`);
console.log(`  Difficulty: ${difficulty}`);
console.log(`  Result: ${stealthTotal >= difficulty ? '✓ You sneak past!' : '✗ You are spotted!'}\n`);

// Scenario 10: Initiative
console.log('SCENARIO 10: Battle start - Roll initiative!');
console.log('Combat begins!\n');
const combatants = [
  { name: 'You', dex: 3 },
  { name: 'Enemy 1', dex: 1 },
  { name: 'Enemy 2', dex: 2 },
];

const initiatives = combatants.map(c => ({
  ...c,
  roll: roller.roll('d20'),
  get total() { return this.roll.total + this.dex; }
}));

initiatives.sort((a, b) => b.total - a.total);

console.log('  Initiative order:');
initiatives.forEach((init, i) => {
  console.log(`  ${i + 1}. ${init.name}: d20(${init.roll.total}) + ${init.dex} = ${init.total}`);
});
console.log();
