-- Allow companies to delete their own offers
CREATE POLICY "Companies delete own offers" ON offers
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM company_members
      WHERE company_members.company_id = offers.company_id
      AND company_members.user_id = auth.uid()
    )
  );
