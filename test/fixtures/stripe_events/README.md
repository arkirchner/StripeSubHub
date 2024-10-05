# How to record/update the Stripe event fixtures.

## Record customer subscription event fixtures

1.  Listen to customer.subscription.created and customer.subscription.updated

        % stripe listen --format JSON \
        %               --events customer.subscription.created,customer.subscription.updated

2.  Trigger both events by triggering a subscription update

        % stripe trigger customer.subscription.updated

3.  Copy the recorded events into the fixture folder (event_type == filename).

## Record invoice event fixtures 

        % stripe listen --format JSON \
        %               --events invoice.created,invoice.updated

2.  Trigger both events by triggering an invoice update

        % stripe trigger invoice.updated

3.  Copy the recorded events into the fixture folder (event_type == filename).
