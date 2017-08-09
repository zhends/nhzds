#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

#-- encoding: UTF-8
module RedmineDiff
  class Diff
    VERSION = 0.3

    def self.lcs(a, b)
      astart = 0
      bstart = 0
      afinish = a.length - 1
      bfinish = b.length - 1
      mvector = []

      # First we prune off any common elements at the beginning
      while astart <= afinish && bstart <= afinish && a[astart] == b[bstart]
        mvector[astart] = bstart
        astart += 1
        bstart += 1
      end

      # now the end
      while astart <= afinish && bstart <= bfinish && a[afinish] == b[bfinish]
        mvector[afinish] = bfinish
        afinish -= 1
        bfinish -= 1
      end

      bmatches = b.reverse_hash(bstart..bfinish)
      thresh = []
      links = []

      (astart..afinish).each do |aindex|
        aelem = a[aindex]
        next unless bmatches.has_key? aelem
        k = nil
        bmatches[aelem].reverse_each { |bindex|
          if k && (thresh[k] > bindex) && (thresh[k - 1] < bindex)
            thresh[k] = bindex
          else
            k = thresh.replacenextlarger(bindex, k)
          end
          links[k] = [(k == 0) ? nil : links[k - 1], aindex, bindex] if k
        }
      end

      if !thresh.empty?
        link = links[thresh.length - 1]
        while link
          mvector[link[1]] = link[2]
          link = link[0]
        end
      end

      mvector
    end

    def makediff(a, b)
      mvector = Diff.lcs(a, b)
      ai = bi = 0
      while ai < mvector.length
        bline = mvector[ai]
        if bline
          while bi < bline
            discardb(bi, b[bi])
            bi += 1
          end
          match(ai, bi)
          bi += 1
        else
          discarda(ai, a[ai])
        end
        ai += 1
      end
      while ai < a.length
        discarda(ai, a[ai])
        ai += 1
      end
      while bi < b.length
        discardb(bi, b[bi])
        bi += 1
      end
      match(ai, bi)
      1
    end

    def compactdiffs
      diffs = []
      @diffs.each do |df|
        i = 0
        curdiff = []
        while i < df.length
          whot = df[i][0]
          s = @isstring ? df[i][2].chr : [df[i][2]]
          p = df[i][1]
          last = df[i][1]
          i += 1
          while df[i] && df[i][0] == whot && df[i][1] == last + 1
            s << df[i][2]
            last  = df[i][1]
            i += 1
          end
          curdiff.push [whot, p, s]
        end
        diffs.push curdiff
      end
      diffs
    end

    attr_reader :diffs, :difftype

    def initialize(diffs_or_a, b = nil, isstring = nil)
      if b.nil?
        @diffs = diffs_or_a
        @isstring = isstring
      else
        @diffs = []
        @curdiffs = []
        makediff(diffs_or_a, b)
        @difftype = diffs_or_a.class
      end
    end

    def match(_ai, _bi)
      @diffs.push @curdiffs unless @curdiffs.empty?
      @curdiffs = []
    end

    def discarda(i, elem)
      @curdiffs.push ['-', i, elem]
    end

    def discardb(i, elem)
      @curdiffs.push ['+', i, elem]
    end

    def compact
      Diff.new(compactdiffs)
    end

    def compact!
      @diffs = compactdiffs
    end

    def inspect
      @diffs.inspect
    end
  end
end

module Diffable
  def diff(b)
    RedmineDiff::Diff.new(self, b)
  end

  # Create a hash that maps elements of the array to arrays of indices
  # where the elements are found.

  def reverse_hash(range = (0...length))
    revmap = {}
    range.each do |i|
      elem = self[i]
      if revmap.has_key? elem
        revmap[elem].push i
      else
        revmap[elem] = [i]
      end
    end
    revmap
  end

  def replacenextlarger(value, high = nil)
    high ||= length
    if self.empty? || value > self[-1]
      push value
      return high
    end
    # binary search for replacement point
    low = 0
    while low < high
      index = (high + low) / 2
      found = self[index]
      return nil if value == found
      if value > found
        low = index + 1
      else
        high = index
      end
    end

    self[low] = value
    # $stderr << "replace #{value} : 0/#{low}/#{init_high} (#{steps} steps) (#{init_high-low} off )\n"
    # $stderr.puts self.inspect
    # gets
    # p length - low
    low
  end

  def patch(diff)
    newary = nil
    if diff.difftype == String
      newary = diff.difftype.new('')
    else
      newary = diff.difftype.new
    end
    ai = 0
    bi = 0
    diff.diffs.each do |d|
      d.each { |mod|
        case mod[0]
        when '-'
          while ai < mod[1]
            newary << self[ai]
            ai += 1
            bi += 1
          end
          ai += 1
        when '+'
          while bi < mod[1]
            newary << self[ai]
            ai += 1
            bi += 1
          end
          newary << mod[2]
          bi += 1
        else
          raise 'Unknown diff action'
        end
      }
    end
    while ai < length
      newary << self[ai]
      ai += 1
      bi += 1
    end
    newary
  end
end

class Array
  include Diffable
end

class String
  include Diffable
end

#   = Diff
#   (({diff.rb})) - computes the differences between two arrays or
#   strings. Copyright (C) 2001 Lars Christensen
#
#   == Synopsis
#
#       diff = Diff.new(a, b)
#       b = a.patch(diff)
#
#   == Class Diff
#   === Class Methods
#   --- Diff.new(a, b)
#   --- a.diff(b)
#         Creates a Diff object which represent the differences between
#         ((|a|)) and ((|b|)). ((|a|)) and ((|b|)) can be either be arrays
#         of any objects, strings, or object of any class that include
#         module ((|Diffable|))
#
#   == Module Diffable
#   The module ((|Diffable|)) is intended to be included in any class for
#   which differences are to be computed. Diffable is included into String
#   and Array when (({diff.rb})) is (({require}))'d.
#
#   Classes including Diffable should implement (({[]})) to get element at
#   integer indices, (({<<})) to append elements to the object and
#   (({ClassName#new})) should accept 0 arguments to create a new empty
#   object.
#
#   === Instance Methods
#   --- Diffable#patch(diff)
#         Applies the differences from ((|diff|)) to the object ((|obj|))
#         and return the result. ((|obj|)) is not changed. ((|obj|)) and
#         can be either an array or a string, but must match the object
#         from which the ((|diff|)) was created.
