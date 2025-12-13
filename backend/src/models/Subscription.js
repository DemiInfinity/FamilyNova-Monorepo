const { getSupabase } = require('../config/database');

class Subscription {
  constructor(data) {
    this.id = data.id;
    this.userId = data.user_id;
    this.plan = data.plan || 'free';
    this.status = data.status || 'active';
    this.billingCycle = data.billing_cycle;
    this.startDate = data.start_date;
    this.endDate = data.end_date;
    this.nextBillingDate = data.next_billing_date;
    this.cancelledAt = data.cancelled_at;
    this.provider = data.provider;
    this.providerSubscriptionId = data.provider_subscription_id;
    this.receipt = data.receipt;
    this.isTrial = data.is_trial || false;
    this.trialEndDate = data.trial_end_date;
    this.createdAt = data.created_at;
    this.updatedAt = data.updated_at;
  }

  static async findByUserId(userId) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error || !data) return null;
    return new Subscription(data);
  }

  static async find(filter = {}) {
    const supabase = getSupabase();
    let query = supabase.from('subscriptions').select('*');

    if (filter.userId) query = query.eq('user_id', filter.userId);
    if (filter.status) query = query.eq('status', filter.status);
    if (filter.plan) query = query.eq('plan', filter.plan);

    const { data, error } = await query;
    if (error) throw error;
    return data ? data.map(s => new Subscription(s)) : [];
  }

  static async create(subscriptionData) {
    const supabase = getSupabase();
    const dbData = {
      user_id: subscriptionData.userId,
      plan: subscriptionData.plan || 'free',
      status: subscriptionData.status || 'active',
      billing_cycle: subscriptionData.billingCycle || null,
      start_date: subscriptionData.startDate || new Date().toISOString(),
      end_date: subscriptionData.endDate || null,
      next_billing_date: subscriptionData.nextBillingDate || null,
      provider: subscriptionData.provider || null,
      provider_subscription_id: subscriptionData.providerSubscriptionId || null,
      receipt: subscriptionData.receipt || null,
      is_trial: subscriptionData.isTrial || false,
      trial_end_date: subscriptionData.trialEndDate || null
    };

    const { data, error } = await supabase
      .from('subscriptions')
      .insert(dbData)
      .select()
      .single();

    if (error) throw error;
    return new Subscription(data);
  }

  async save() {
    const supabase = getSupabase();
    const dbData = {
      plan: this.plan,
      status: this.status,
      billing_cycle: this.billingCycle,
      start_date: this.startDate,
      end_date: this.endDate,
      next_billing_date: this.nextBillingDate,
      cancelled_at: this.cancelledAt,
      provider: this.provider,
      provider_subscription_id: this.providerSubscriptionId,
      receipt: this.receipt,
      is_trial: this.isTrial,
      trial_end_date: this.trialEndDate
    };

    const { data, error } = await supabase
      .from('subscriptions')
      .update(dbData)
      .eq('id', this.id)
      .select()
      .single();

    if (error) throw error;
    Object.assign(this, new Subscription(data));
    return this;
  }
}

module.exports = Subscription;
