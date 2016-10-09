class ClustersController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: :bypass_ip?
  before_action :set_campus!, only: [:index]
  before_action :set_data!, only: [:index]

  def index
  end

  private

  def set_campus!
    @campus_id = :'1'

    @campus = Rails.application.config.meet2code.campus[@campus_id]
  end

  def set_data!
    @names = @campus.clusters.values.map(&:name)
    base = @campus.clusters.values.map(&:mapping)

    @data = base.map do |cluster_value|
      rows_length = cluster_value.map { |r| r.inject(0) { |n, s| n + (s == 'x' ? 1 : 0) } }

      { slots: rows_length.reduce(&:+), percent: 0, charts: [] }
    end

    @columns = base.map do |cluster_value|
      # Récupère le numbre de poste pour chaque rangée
      rows_length = cluster_value.map { |r| r.inject(0) { |n, s| n + (s == 'x' || s == '-' ? 1 : 0) } }
      # Clone la rangée avec le plus de poste
      columns = cluster_value[rows_length.index(rows_length.max)].clone
      # Renvoi une liste de colonnes
      columns.map!.with_index do |v, i|
        pred = i.pred == -1 ? [0, ''] : columns[i.pred]

        [pred[0] + (v == 'x' || v == '-' ? 1 : 0), v]
      end.map! { |k, v| v == 'x' || v == '-' ? k.to_s : '' }
    end

    @maps = base.map.with_index do |cluster_value, cluster_index|
      user_history = UserHistory.campus(@campus_id.to_s).cluster(cluster_index + 1)
      @data[cluster_index][:charts] = user_history.chart
      histories = user_history.logged.includes(:user_info_short).map { |history| [history.host, history.user_info_short || UserInfoShort.new] }.to_h
      @data[cluster_index][:percent] = histories.length.to_f / @data[cluster_index][:slots] * 100
      @data[cluster_index][:slots] -= histories.length

      cluster_value.map.with_index do |row_value, row_index|
        row_length = row_value.length - 1
        columns = row_value.clone

        columns.map!.with_index do |v, i|
          pred = i.pred == -1 ? [0, ''] : columns[i.pred]

          [pred[0] + (v == 'x' || v == '-' ? 1 : 0), v]
        end.map! { |k, v| k }

        [row_index + 1, row_value.map.with_index do |station_value, station_index|
          case station_value
          when 'x', '-' then
            kind = :station
            class_name = %w(station)
            pred_station = row_value[station_index.pred]
            next_station = row_value[station_index.next]
            host = %Q(e#{cluster_index + 1}r#{row_index + 1}p#{columns[station_index]})
            user = histories[host]

            if station_index.zero? || (pred_station != 'x' && pred_station != '-')
              class_name << 'block-begin'
            elsif station_index == row_length || (next_station != 'x' && next_station != '-')
              class_name << 'block-end'
            elsif (pred_station == 'x' || pred_station == '-') && (next_station == 'x' || next_station == '-')
              class_name << 'block-middle'
            end

            if user
              class_name << (user.piscine? ? 'station-warning' : 'station-success')

              unless user.new_record?
                data = { login: user.login, title: user.display_name, placement: 'auto', avatar: user.image_url }
              end
            else
              class_name << 'station-default'
            end
          when 'o' then
            kind = :obstacle
            class_name = %w(block-begin block-end station station-obstacle)
          else
            kind = :space
            class_name = %w(space)
          end

          { kind: kind, class: class_name || [], host: host, data: data || {} }
        end]
      end.to_h.sort { |a, b| b[0] <=> a[0] }
    end

    @charts = @data.map.with_index do |data, index|
      {
        name: @names[index],
        pointInterval: 24 * 3600 * 1000,
        data: data[:charts]
      }
    end
  end
end
