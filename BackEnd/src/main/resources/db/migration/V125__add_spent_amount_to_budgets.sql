-- V125__add_spent_amount_to_budgets.sql
-- Keep the persisted Budget entity aligned with the budgets table.
-- Existing budgets start with no recorded spend; the value can be updated
-- as spending data is captured by the budget module.
ALTER TABLE budgets
    ADD COLUMN spent DECIMAL(10, 2) NOT NULL DEFAULT 0;
