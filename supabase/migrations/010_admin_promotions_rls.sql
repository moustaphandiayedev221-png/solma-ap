-- Admin peut gérer les codes promo (CRUD)
CREATE POLICY "Admin can insert promotions"
  ON public.promotions FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update promotions"
  ON public.promotions FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete promotions"
  ON public.promotions FOR DELETE
  USING (public.is_admin());
