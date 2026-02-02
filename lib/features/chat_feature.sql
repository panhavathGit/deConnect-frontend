Run This SQL for Group Chat:
sql
-- ============================================================
-- GROUP CHAT RPC FUNCTIONS
-- ============================================================

-- 1. Drop existing functions
DROP FUNCTION IF EXISTS generate_invite_code() CASCADE;
DROP FUNCTION IF EXISTS create_group_chat(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS join_group_by_code(TEXT) CASCADE;
DROP FUNCTION IF EXISTS regenerate_invite_code(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_my_groups() CASCADE;

-- 2. Generate random 8-character code
CREATE FUNCTION generate_invite_code()
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
  chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result TEXT := '';
BEGIN
  FOR i IN 1..8 LOOP
    result := result || substr(chars, floor(random() * 36 + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$;

-- 3. Create group chat
CREATE FUNCTION create_group_chat(p_name TEXT, p_description TEXT DEFAULT NULL)
RETURNS TABLE (room_id UUID, invite_code TEXT)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_room_id UUID;
  v_invite_code TEXT;
BEGIN
  -- Generate unique invite code
  LOOP
    v_invite_code := generate_invite_code();
    EXIT WHEN NOT EXISTS (SELECT 1 FROM chat_rooms WHERE chat_rooms.invite_code = v_invite_code);
  END LOOP;

  -- Create room
  INSERT INTO chat_rooms (name, is_group, created_by, invite_code, description)
  VALUES (p_name, TRUE, auth.uid(), v_invite_code, p_description)
  RETURNING id INTO v_room_id;

  -- Add creator as admin
  INSERT INTO room_members (room_id, user_id, role, is_admin, joined_at)
  VALUES (v_room_id, auth.uid(), 'admin', TRUE, NOW());

  RETURN QUERY SELECT v_room_id, v_invite_code;
END;
$$;
GRANT EXECUTE ON FUNCTION create_group_chat(TEXT, TEXT) TO authenticated;

-- 4. Join group by code
CREATE FUNCTION join_group_by_code(p_code TEXT)
RETURNS TABLE (success BOOLEAN, room_id UUID, room_name TEXT, message TEXT)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_room_id UUID;
  v_room_name TEXT;
BEGIN
  -- Find group
  SELECT id, name INTO v_room_id, v_room_name
  FROM chat_rooms
  WHERE invite_code = UPPER(TRIM(p_code)) AND is_group = TRUE;

  IF v_room_id IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Invalid invite code'::TEXT;
    RETURN;
  END IF;

  -- Check if already member
  IF EXISTS (SELECT 1 FROM room_members WHERE room_id = v_room_id AND user_id = auth.uid()) THEN
    RETURN QUERY SELECT TRUE, v_room_id, v_room_name, 'Already a member'::TEXT;
    RETURN;
  END IF;

  -- Add as member
  INSERT INTO room_members (room_id, user_id, role, is_admin, joined_at)
  VALUES (v_room_id, auth.uid(), 'member', FALSE, NOW());

  RETURN QUERY SELECT TRUE, v_room_id, v_room_name, 'Successfully joined'::TEXT;
END;
$$;
GRANT EXECUTE ON FUNCTION join_group_by_code(TEXT) TO authenticated;

-- 5. Get my groups
CREATE FUNCTION get_my_groups()
RETURNS TABLE (
  room_id UUID, room_name TEXT, description TEXT, avatar_url TEXT,
  invite_code TEXT, member_count BIGINT, is_admin BOOLEAN,
  created_at TIMESTAMPTZ, last_message TEXT, last_message_time TIMESTAMPTZ, unread_count BIGINT
)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cr.id, cr.name, cr.description, cr.avatar_url,
    CASE WHEN rm.is_admin THEN cr.invite_code ELSE NULL END,
    (SELECT COUNT(*) FROM room_members WHERE room_members.room_id = cr.id),
    rm.is_admin,
    cr.created_at,
    (SELECT m.content FROM messages m WHERE m.room_id = cr.id AND m.is_deleted = FALSE ORDER BY m.created_at DESC LIMIT 1),
    (SELECT m.created_at FROM messages m WHERE m.room_id = cr.id AND m.is_deleted = FALSE ORDER BY m.created_at DESC LIMIT 1),
    (SELECT COUNT(*) FROM messages m WHERE m.room_id = cr.id AND m.sender_id != auth.uid() AND m.is_read = FALSE)
  FROM chat_rooms cr
  JOIN room_members rm ON rm.room_id = cr.id
  WHERE rm.user_id = auth.uid() AND cr.is_group = TRUE
  ORDER BY last_message_time DESC NULLS LAST;
END;
$$;
GRANT EXECUTE ON FUNCTION get_my_groups() TO authenticated;

-- 6. Regenerate invite code (admin only)
CREATE FUNCTION regenerate_invite_code(p_room_id UUID)
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_new_code TEXT;
BEGIN
  -- Check admin
  IF NOT EXISTS (SELECT 1 FROM room_members WHERE room_id = p_room_id AND user_id = auth.uid() AND is_admin = TRUE) THEN
    RAISE EXCEPTION 'Only admin can regenerate';
  END IF;

  -- Generate new code
  LOOP
    v_new_code := generate_invite_code();
    EXIT WHEN NOT EXISTS (SELECT 1 FROM chat_rooms WHERE invite_code = v_new_code);
  END LOOP;

  UPDATE chat_rooms SET invite_code = v_new_code WHERE id = p_room_id;
  RETURN v_new_code;
END;
$$;
GRANT EXECUTE ON FUNCTION regenerate_invite_code(UUID) TO authenticated;

SELECT '✅ All group chat functions created!' as status;