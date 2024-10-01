# How to record/update the Stripe event fixtures.

1.  How to record/update the Stripe event fixtures.

        % stripe listen --format JSON \
        %               --events customer.subscription.created,customer.subscription.updated,invoice.updated


2.  Trigger the events and copy them into the fixture files.

        % stripe trigger customer.subscription.updated
        % stripe trigger invoice.updated

