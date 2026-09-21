WITH bookings AS (
  SELECT
    ('00000000-0000-0000-0000-' || lpad(gs::text, 12, '0'))::uuid AS id,
    (ARRAY[
      '11111111-1111-1111-1111-111111111111',
      '22222222-2222-2222-2222-222222222222',
      '33333333-3333-3333-3333-333333333333'
    ])[1 + (gs % 3)]::uuid AS org_id,
    'hotel-' || (1 + (gs % 20)) AS hotel_id,
    (ARRAY['delhi', 'mumbai', 'bengaluru', 'goa', 'jaipur'])[1 + (gs % 5)] AS city,
    CURRENT_DATE + (gs % 45) AS checkin_date,
    CURRENT_DATE + (gs % 45) + 2 + (gs % 5) AS checkout_date,
    (1500 + (gs * 137 % 12000))::numeric(12,2) AS amount,
    (ARRAY['confirmed', 'cancelled', 'completed', 'pending'])[1 + (gs % 4)] AS status,
    CURRENT_TIMESTAMP - ((gs % 90) || ' days')::interval AS created_at
  FROM generate_series(1, 150) AS gs
)
INSERT INTO hotel_bookings (id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at FROM bookings;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
  id,
  CASE WHEN status = 'cancelled' THEN 'booking.cancelled' ELSE 'booking.created' END,
  jsonb_build_object('source', 'seed', 'city', city, 'status', status),
  created_at
FROM hotel_bookings
WHERE (substring(id::text FROM 36 FOR 1)::int % 2) = 0;

