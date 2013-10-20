# coding:utf-8
require 'spec_helper'
require 'parsecom'

describe Parse::Query, 'when it builds conditions' do
  it 'should build a correct "where" parameter' do
    query = Parse::Query.new ClassA
    query.to_params.should be_empty

    query.where :column1 => 'val1'
    query.to_params.should have_params('where' => '{"column1":"val1"}')

    query.where.clear
    query.to_params.should be_empty

    query.where :column1 => 'val1', :column2 => 'val2'
    query.to_params.should have_params('where' => '{"column1":"val1","column2":"val2"}')

    query.where :column3 => 'val3'
    query.to_params.should have_params('where' => '{"column1":"val1","column2":"val2","column3":"val3"}')

    query.where.clear

    query.where do
      column(:playerName).eq('Sean Plott')
      column(:cheatMode).eq(false)
    end
    query.to_params.should have_params('where' => '{"playerName":"Sean Plott","cheatMode":false}')
    query.where.clear

    query.where do
      column(:score).gte(1000).lte(3000)
    end
    query.to_params.should have_params('where' => '{"score":{"$gte":1000,"$lte":3000}}')
    query.where.clear

    query.where do
      column(:score).in(1, 3 ,5, 7, 9)
    end
    query.to_params.should have_params('where' => '{"score":{"$in":[1, 3, 5, 7, 9]}}')
    query.where.clear

    query.where do
      column(:playerName).nin("Jonathan Walsh","Dario Wunsch","Shawn Simon")
    end
    query.to_params.should have_params('where' => '{"playerName":{"$nin":["Jonathan Walsh", "Dario Wunsch", "Shawn Simon"]}}')
    query.where.clear

    query.where do
      column(:score).exists(true)
    end
    query.to_params.should have_params('where' => '{"score":{"$exists":true}}')
    query.where.clear

    query.where do
      column(:score).exists(false)
    end
    query.to_params.should have_params('where' => '{"score":{"$exists":false}}')
    query.where.clear

    query.where do
      subquery = subquery_for :Team
      subquery.where do
        column(:winPct).gt(0.5)
      end
      subquery.key = 'city'
      column(:hometown).select(subquery)
    end
    query.to_params.should have_params('where' => '{"hometown":{"$select":{"query":{"className":"Team","where":{"winPct":{"$gt":0.5}}},"key":"city"}}}')
    query.where.clear

    query.where do
      column(:arrayKey).contains(2)
    end
    query.to_params.should have_params('where' => '{"arrayKey":2}')
    query.where.clear

    query.where do
      column(:arrayKey).all(2,3,4)
    end
    query.to_params.should have_params('where' => '{"arrayKey":{"$all":[2, 3, 4]}}')
    query.where.clear

    query.where do
      post = Parse::Object(:Post).new :objectId => '8TOXdXf3tz'
      column(:post).eq(post)
    end
    query.to_params.should have_params('where' => '{"post":{"__type":"Pointer","className":"Post","objectId":"8TOXdXf3tz"}}')
    query.where.clear

    query.where do
      subquery = subquery_for :Post
      subquery.where do
        column(:image).exists(true)
      end
      column(:post).in_query(subquery)
    end
    query.to_params.should have_params('where' => '{"post":{"$inQuery":{"where":{"image":{"$exists":true}},"className":"Post"}}}')
    query.where.clear

    query.where do
      subquery = subquery_for :Post
      subquery.where do
        column(:image).exists(true)
      end
      column(:post).not_in_query(subquery)
    end
    query.to_params.should have_params('where' => '{"post":{"$notInQuery":{"where":{"image":{"$exists":true}},"className":"Post"}}}')
    query.where.clear

    query.where do
      pointer = Parse::Pointer.new('className' => 'Post', 'objectId' => '8TOXdXf3tz')
      related_to :likes, pointer
    end
    query.to_params.should have_params('where' => '{"$relatedTo":{"object":{"__type":"Pointer","className":"Post","objectId":"8TOXdXf3tz"},"key":"likes"}}')
    query.where.clear

    query.where do
      column(:wins).gt(150).or column(:wins).lt(5)
    end
    query.to_params.should have_params('where' => '{"$or":[{"wins":{"$gt":150}},{"wins":{"$lt":5}}]}')
    query.where.clear

    query.where do
      or_condition column(:wins).gt(150), column(:wins).lt(5)
    end
    query.to_params.should have_params('where' => '{"$or":[{"wins":{"$gt":150}},{"wins":{"$lt":5}}]}')
    query.where.clear

    query.where do
      or_condition column(:wins).gt(150), column(:wins).lt(5), column(:loses).lt(5)
    end
    query.to_params.should have_params('where' => '{"$or":[{"wins":{"$gt":150}},{"wins":{"$lt":5}},{"loses":{"$lt":5}}]}')
    query.where.clear

    geo_point1 = Parse::GeoPoint.new :latitude => 12, :longitude => 34
    geo_point2 = Parse::GeoPoint.new :latitude => 56, :longitude => 78
    query.where do
      column(:location).near_sphere(geo_point1)
    end
    query.to_params.should have_params('where' => '{"location":{"$nearSphere":{"__type":"GeoPoint","latitude":12,"longitude":34}}}')
    query.where.clear

    query.where do
      column(:location).near_sphere(geo_point1).max_distance_in_miles(10)
    end
    query.to_params.should have_params('where' => '{"location":{"$nearSphere":{"__type":"GeoPoint","latitude":12,"longitude":34},"$maxDistanceInMiles":10}}')
    query.where.clear

    query.where do
      column(:location).within(geo_point1, geo_point2)
    end
    query.to_params.should have_params('where' => '{"location":{"$within":{"$box":[{"__type":"GeoPoint","latitude":12,"longitude":34},{"__type":"GeoPoint","latitude":56,"longitude":78}]}}}')
    query.where.clear
  end
  
  it 'should build a correct "order" parameter' do
    query = Parse::Query.new ClassA
    query.order 'score', '-name'
    query.to_params.should == 'order=score,-name'
    query.order.clear

    query.order_desc '-score', 'name'
    query.to_params.should == 'order=score,-name'
    query.order.clear

    query.order 'score'
    query.order_desc 'name'
    query.to_params.should == 'order=score,-name'
    query.order.clear
  end

  it 'should success request' do
    query = Parse::Query.new(ClassA).
      order('createdAt').
      keys('columnB').
      limit(3).
      where {column(:columnB).gt 5}
    # query.invoke
    query.to_params.should have_params(
      'order' => 'createdAt', 
      'keys' => 'columnB', 
      'limit' => 3, 
      'where' => '{"columnB":{"$gt":5}}'
    )
  end
end
