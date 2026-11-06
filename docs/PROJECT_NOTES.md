# Project notes

## Modeling decisions

- **Customers and orders:** one customer can place many orders.
- **Order items:** composite key prevents duplicate product lines within an order.
- **Historical pricing:** `order_items.unit_price` preserves the price charged when the order was recorded.
- **Payments:** separate table supports multiple payments per order, although the sample uses one full payment for each paid order.
- **Inventory movements:** signed quantities document sales and can be extended to purchase and adjustment events.
- **Revenue recognition:** analytics use orders marked `paid`; this is a simplified retail reporting rule, not formal accounting advice.

## Validation checks

After the first three scripts, `06_validation.sql` should report 6 customers, 8 products, 12 orders, and 9 payments. There should be no unmatched paid balances or negative stock.

## Limitations

The seed is illustrative and not a complete accounting or inventory ledger. The stock snapshot is not calculated from the movement history. The transaction demonstration uses `ROLLBACK` and should not be treated as a production checkout implementation. The system has no authentication, UI, automated tests, or deployment.

## Possible future enhancements

- Stored procedure with proper error handling and stock locking.
- Automated integration tests against a disposable MySQL database.
- Backend REST API and frontend dashboard.
- Returns/refunds and payment status transitions.
- Inventory opening balances and reconciliation.
