-- Enable Row Level Security (Idempotent usually, or harmless if on)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT
    USING (user_id = auth.uid());

-- Policy: Users can update (mark as read) their own notifications
DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE
    USING (user_id = auth.uid());

-- Policy: Users can delete their own notifications
DROP POLICY IF EXISTS "Users can delete their own notifications" ON public.notifications;
CREATE POLICY "Users can delete their own notifications" ON public.notifications
    FOR DELETE
    USING (user_id = auth.uid());

-- Policy: Users can insert notifications
DROP POLICY IF EXISTS "Users can insert notifications" ON public.notifications;
CREATE POLICY "Users can insert notifications" ON public.notifications
    FOR INSERT
    WITH CHECK (true);
