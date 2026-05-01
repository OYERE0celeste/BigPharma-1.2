const orderController = require('../api/controllers/orderController');

const status = 'en_preparation';
const currentStatus = 'en_attente';
const allowed = orderController.ORDER_TRANSITIONS[currentStatus] || [];

console.log('Label for currentStatus:', orderController.ORDER_STATUS_LABELS[currentStatus]);
console.log('Label for targetStatus:', orderController.ORDER_STATUS_LABELS[status]);

if (allowed.includes(status)) {
  console.log('SUCCESS: Transition is allowed in the current code.');
} else {
  console.log('FAILURE: Transition is NOT allowed in the current code.');
}
