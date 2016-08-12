module Gibbon
  class BatchedRequest < Request
    def initialize(batch)
      @batch = batch
      @path_parts = []
    end

    def create(params: nil, headers: nil, body: nil, operation_id: nil)
      puts 'WARNING Discarding individual operation headers on batch request!' if debug && !headers.nil?
      batch.enqueue(self, method: :post, path: path, params: params, body: body)
    ensure
      reset
    end

    def update(params: nil, headers: nil, body: nil, operation_id: nil)
      batch.enqueue(self, method: :patch, path: path, params: params, body: body)
    ensure
      reset
    end

    def upsert(params: nil, headers: nil, body: nil, operation_id: nil)
      batch.enqueue(self, method: :put, path: path, params: params, body: body)
    ensure
      reset
    end

    def retrieve(params: nil, headers: nil, operation_id: nil)
      batch.enqueue(self, method: :get, path: path, params: params)
    ensure
      reset
    end

    def delete(params: nil, headers: nil, operation_id: nil)
      batch.enqueue(self, method: :delete, path: path, params: params)
    ensure
      reset
    end
  end

  class Batch
    attr_reader :operations

    def initialize
      @operations = []
    end

    def enqueue(operation)
      @operations << operation
    end
  end
end
