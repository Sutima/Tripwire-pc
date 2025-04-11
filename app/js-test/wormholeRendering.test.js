const assert = require('assert');
const { include } = require('./helpers/helpers');
include('app/js/wormholeRendering');

describe('Wormhole rendering', () => {
	// Something with multiple 'from'
	const D382 = {"life":"16 Hours","from":["Class-2","J055520","J110145","J164710","J200727","J174618"],"leadsTo":"Class-2","mass":2000000000,"jump":375000000}
	it('should render the full info if unknown from system', () => {
		const result = wormholeRendering.renderWormholeType(D382, 'D382');
		assert.equal(result, '<b>D382</b>: <span class="wh class-2">C2</span>,<span class="wh class-14">J055520</span>,<span class="wh class-15">J110145</span>,<span class="wh class-16">J164710</span>,<span class="wh class-17">J200727</span>,<span class="wh class-18">J174618</span>➔<span class="wh class-2">C2</span> (375kt)');
	});
	it('should render with the given class if known', () => {
		const result = wormholeRendering.renderWormholeType(D382, 'D382', 'Class-2');
		assert.equal(result, '<b>D382</b>: <span class="wh class-2">C2</span>➔<span class="wh class-2">C2</span> (375kt)');
	});
	it('should render with the class from single system if known', () => {
		const result = wormholeRendering.renderWormholeType(D382, 'D382', 'J210536');
		assert.equal(result, '<b>D382</b>: <span class="wh class-2">C2</span>➔<span class="wh class-2">C2</span> (375kt)');
	});	
	it('should render with the exact system if in valid list', () => {
		const result = wormholeRendering.renderWormholeType(D382, 'D382', 'J110145');
		assert.equal(result, '<b>D382</b>: <span class="wh class-15">J110145</span>➔<span class="wh class-2">C2</span> (375kt)');
	});		
	it('should render with the exact system object if in valid list', () => {
		const result = wormholeRendering.renderWormholeType(D382, 'D382', { name: 'J110145' });
		assert.equal(result, '<b>D382</b>: <span class="wh class-15">J110145</span>➔<span class="wh class-2">C2</span> (375kt)');
	});	
	it('should render the full info if system matches no options', () => {
		const result = wormholeRendering.renderWormholeType(D382, 'D382', 'Jita');
		assert.equal(result, '<b>D382</b>: <span class="wh class-2">C2</span>,<span class="wh class-14">J055520</span>,<span class="wh class-15">J110145</span>,<span class="wh class-16">J164710</span>,<span class="wh class-17">J200727</span>,<span class="wh class-18">J174618</span>➔<span class="wh class-2">C2</span> (375kt)');
	});	
});