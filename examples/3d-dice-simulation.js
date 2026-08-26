const DiceRoller = require('../src/DiceRoller');

// Example: Simulating 3D dice rolls
// In a real browser environment with Three.js, you can use Dice3DAnimator
// This example shows how to integrate with the roller for simulation

const roller = new DiceRoller();

console.log('=== 3D DICE ROLL SIMULATION ===\n');

// Example 1: D&D Combat with visible rolls
console.log('COMBAT SCENARIO: Initiating battle\n');

const participants = [
  { name: 'Player', dex: 3 },
  { name: 'Goblin', dex: 1 },
  { name: 'Orc', dex: 2 }
];

console.log('Rolling Initiative...');
const initiatives = participants.map(p => {
  const roll = roller.roll('d20');
  return {
    ...p,
    roll: roll.total,
    total: roll.total + p.dex,
    message: roll.getCriticalMessage()
  };
});

initiatives.sort((a, b) => b.total - a.total);

console.log('\n📊 Initiative Order:');
initiatives.forEach((init, i) => {
  let line = `  ${i + 1}. ${init.name}: ${init.roll} + ${init.dex} = ${init.total}`;
  if (init.message) {
    line += ` [${init.message}]`;
  }
  console.log(line);
});
console.log();

// Example 2: Attack sequence
console.log('\n⚔️ ATTACK SEQUENCE\n');

const attacker = 'Player';
const target = 'Goblin';
const ac = 12; // Armor Class

console.log(`${attacker} attacks ${target}!`);
const attackRoll = roller.roll('d20+5');
console.log(`  Attack Roll: ${attackRoll.toString()}`);

if (attackRoll.total >= ac) {
  console.log(`  ✓ HIT! (AC ${ac})`);
  
  // Determine if critical
  const isCritical = attackRoll.total === 25; // 20 + 5 modifier
  
  const damageRoll = isCritical ? roller.roll('2d8+3') : roller.roll('1d8+3');
  console.log(`  Damage: ${damageRoll.toString()}`);
  console.log(`  ${target} takes ${damageRoll.total} damage!`);
} else {
  console.log(`  ✗ MISS! (AC ${ac})`);
}

console.log();

// Example 3: Spell casting with area effect
console.log('\n✨ CASTING FIREBALL\n');

console.log('3 enemies in blast radius!');
const affectedEnemies = ['Goblin 1', 'Goblin 2', 'Orc Warrior'];
const saveDC = 15;

affectedEnemies.forEach((enemy, index) => {
  const saveThrow = roller.roll('d20+2');
  console.log(`\n  ${enemy}:`);
  console.log(`    Save: ${saveThrow.toString()} vs DC ${saveDC}`);
  
  if (saveThrow.total >= saveDC) {
    console.log(`    ✓ Saved! (half damage)`);
    const halfDamage = Math.ceil(roller.roll('4d6').total / 2);
    console.log(`    Takes ${halfDamage} damage`);
  } else {
    console.log(`    ✗ Failed!`);
    const fullDamage = roller.roll('4d6').total;
    console.log(`    Takes ${fullDamage} damage`);
  }
});

console.log();

// Example 4: Ability check with detailed info
console.log('\n🔍 SKILL CHECK\n');

const checks = [
  { skill: 'Stealth', modifier: 5, dc: 13 },
  { skill: 'Perception', modifier: 2, dc: 15 },
  { skill: 'Arcana', modifier: 4, dc: 12 }
];

checks.forEach(check => {
  const roll = roller.roll('d20');
  const total = roll.total + check.modifier;
  const success = total >= check.dc;
  
  console.log(`${check.skill} Check:`);
  console.log(`  Roll: ${roll.total} + ${check.modifier} = ${total}`);
  console.log(`  DC: ${check.dc}`);
  console.log(`  Result: ${success ? '✓ SUCCESS' : '✗ FAILURE'}`);
  console.log();
});

// Example 5: Multiple rolls with statistics
console.log('\n📈 STATISTICAL ANALYSIS\n');

console.log('Analyzing probability of different rolls...\n');

const diceTypes = ['1d20', '2d10', '3d6', '4d6'];
const stats = diceTypes.map(notation => {
  return roller.getStatistics(notation, 50);
});

stats.forEach((stat, i) => {
  console.log(`${diceTypes[i].toUpperCase()}:`);
  console.log(`  Min: ${stat.min}, Max: ${stat.max}`);
  console.log(`  Avg: ${stat.average}, Median: ${stat.median}`);
  console.log(`  Std Dev: ${stat.stdDev}`);
  console.log();
});

// Example 6: Character creation
console.log('\n👤 CHARACTER CREATION\n');

const abilityNames = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
const abilities = {};

console.log('Rolling ability scores (4d6 drop lowest)...\n');

abilityNames.forEach(ability => {
  const rolls = [
    roller.roll('1d6').total,
    roller.roll('1d6').total,
    roller.roll('1d6').total,
    roller.roll('1d6').total
  ];
  
  const sorted = [...rolls].sort((a, b) => b - a);
  const score = sorted.slice(0, 3).reduce((a, b) => a + b, 0);
  abilities[ability] = score;
  
  console.log(`${ability}: [${rolls.join(', ')}] → drop ${sorted[3]} = ${score}`);
});

console.log('\nFinal Ability Scores:');
console.log(abilities);

console.log('\n✓ Character creation complete!\n');
