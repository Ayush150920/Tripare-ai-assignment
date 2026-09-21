CREATE TABLE hotel_bookings (
  id UUID PRIMARY KEY,
  org_id UUID NOT NULL,
  hotel_id VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  checkin_date DATE NOT NULL,
  checkout_date DATE NOT NULL,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (checkout_date > checkin_date)
);

CREATE TABLE booking_events (
  id BIGSERIAL PRIMARY KEY,
  booking_id UUID NOT NULL REFERENCES hotel_bookings(id) ON DELETE CASCADE,
  event_type VARCHAR(100) NOT NULL,
  payload JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- The leading city and created_at columns support the filter; org_id/status then
-- support grouping and amount is covered for an index-only aggregate when possible.
CREATE INDEX idx_hotel_bookings_city_created_org_status
  ON hotel_bookings (city, created_at, org_id, status) INCLUDE (amount);

CREATE INDEX idx_booking_events_booking_id_created_at
  ON booking_events (booking_id, created_at);

