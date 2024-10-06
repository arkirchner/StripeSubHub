# How to record/update the Stripe event fixtures.

1.  Listen for the application relevant subscriptions with the CLI

        % stripe listen --format JSON \
        %               --events customer.subscription.created,customer.subscription.deleted,invoice.paid

2.  Trigger the events with the CLI

        % stripe trigger customer.subscription.deleted

3.  Copy the events into the fixture folder (event_type == filename).
