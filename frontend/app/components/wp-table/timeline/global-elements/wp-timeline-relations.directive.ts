// -- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
// ++

import {State} from 'reactivestates';
import {Observable} from 'rxjs/Observable';
import {openprojectModule} from '../../../../angular-modules';
import {scopeDestroyed$} from '../../../../helpers/angular-rx-utils';
import {States} from '../../../states.service';
import {RelationsStateValue, WorkPackageRelationsService} from '../../../wp-relations/wp-relations.service';
import {WorkPackageTimelineTableController} from '../container/wp-timeline-container.directive';
import {timelineElementCssClass, TimelineViewParameters} from '../wp-timeline';
import {TimelineRelationElement, workPackagePrefix} from './timeline-relation-element';
import {WorkPackageTimelineCell} from '../cells/wp-timeline-cell';

const DEBUG_DRAW_RELATION_LINES_WITH_COLOR = false;

export const timelineGlobalElementCssClassname = 'relation-line';

function newSegment(vp:TimelineViewParameters,
                    classNames:string[],
                    yPosition:number,
                    top:number,
                    left:number,
                    width:number,
                    height:number,
                    color?:string):HTMLElement {

  const segment = document.createElement('div');
  segment.classList.add(
    timelineElementCssClass,
    timelineGlobalElementCssClassname,
    ...classNames
  );

  // segment.style.backgroundColor = color;
  segment.style.top = ((yPosition * 41) + top) + 'px';
  segment.style.left = left + 'px';
  segment.style.width = width + 'px';
  segment.style.height = height + 'px';

  if (DEBUG_DRAW_RELATION_LINES_WITH_COLOR && color !== undefined) {
    segment.style.zIndex = '9999999';
    if (color !== undefined) {
      segment.style.backgroundColor = color;
    }
  }
  return segment;
}

export class WorkPackageTableTimelineRelations {

  public wpTimeline:WorkPackageTimelineTableController;

  private container:JQuery;

  private workPackagesWithRelations:{ [workPackageId:string]:State<RelationsStateValue> } = {};

  constructor(public $element:ng.IAugmentedJQuery,
              public $scope:ng.IScope,
              public states:States,
              public wpRelations:WorkPackageRelationsService) {
  }

  $onInit() {
    this.container = this.$element.find('.wp-table-timeline--relations');
    this.wpTimeline.onRefreshRequested('relations', (vp:TimelineViewParameters) => this.refreshView());

    this.setupRelationSubscription();
  }

  private refreshView() {
    this.update();
  }

  private get workPackageIdOrder() {
    return this.wpTimeline.workPackageIdOrder;
  }

  /**
   * Refresh relations of visible rows.
   */
  private setupRelationSubscription() {
    // for all visible WorkPackage rows...
    Observable.combineLatest(
      this.states.table.renderedWorkPackages.values$(),
      this.states.table.timelineVisible.values$().filter(v => v.visible)
    )
      .takeUntil(scopeDestroyed$(this.$scope))
      .map(([rendered, visible]) => rendered)
      .subscribe(list => {
        // ... make sure that the corresponding relations are loaded ...
        const wps = _.compact(list.map(row => row.workPackageId) as string[]);
        this.wpRelations.requireAll(wps);

        wps.forEach(wpId => {
          const relationsForWorkPackage = this.wpRelations.state(wpId);
          this.workPackagesWithRelations[wpId] = relationsForWorkPackage;

          // ... once they are loaded, display them.
          relationsForWorkPackage.values$()
            .take(1)
            .subscribe(() => {
              this.renderWorkPackagesRelations([wpId]);
            });
        });
      });

    // When a WorkPackage changes, redraw the corresponding relations
    this.states.workPackages.observeChange()
      .takeUntil(scopeDestroyed$(this.$scope))
      .filter(() => this.states.table.timelineVisible.mapOr(v => v.visible, false))
      .subscribe(([workPackageId]) => {
        this.renderWorkPackagesRelations([workPackageId]);
      });

  }

  private renderWorkPackagesRelations(workPackageIds:string[]) {
    workPackageIds.forEach(workPackageId => {
      const workPackageWithRelation = this.workPackagesWithRelations[workPackageId];
      if (_.isNil(workPackageWithRelation)) {
        return;
      }

      this.removeRelationElementsForWorkPackage(workPackageId);
      const relations = _.values(workPackageWithRelation.value!);
      const relationsList = _.values(relations);
      relationsList.forEach(relation => {

        if (!(relation.type === 'precedes'
          || relation.type === 'follows')) {
          return;
        }

        const elem = new TimelineRelationElement(relation.ids.from, relation);
        this.renderElement(this.wpTimeline.viewParameters, elem);
      });

    });
  }

  private update() {
    this.removeAllVisibleElements();
    this.renderElements();
  }

  private removeRelationElementsForWorkPackage(workPackageId:string) {
    const className = workPackagePrefix(workPackageId);
    const found = this.container.find('.' + className);
    found.remove();
  }

  private removeAllVisibleElements() {
    this.container.find('.' + timelineGlobalElementCssClassname).remove();
  }

  private renderElements() {
    const wpIdsWithRelations:string[] = _.keys(this.workPackagesWithRelations);
    this.renderWorkPackagesRelations(wpIdsWithRelations);

  }

  /**
   * Render a single relation to all shown work packages. Since work packages may occur multiple
   * times in the timeline, iterate all potential combinations and render them.
   * @param vp
   * @param e
   */
  private renderElement(vp:TimelineViewParameters, e:TimelineRelationElement) {
    const involved = e.relation.ids;

    const startCells = this.wpTimeline.workPackageCells(involved.from);
    const endCells = this.wpTimeline.workPackageCells(involved.to);

    // If either sources or targets are not rendered, ignore this relation
    if (startCells.length === 0 || endCells.length === 0) {
      return;
    }

    // Now, render all sources to all targets
    startCells.forEach((startCell) => {
      const idxFrom = this.wpTimeline.workPackageIndex(startCell.classIdentifier);
      endCells.forEach((endCell) => {
        const idxTo = this.wpTimeline.workPackageIndex(endCell.classIdentifier);
        this.renderRelation(vp, e, idxFrom, idxTo, startCell, endCell);
      });
    });
  }

  private renderRelation(
    vp:TimelineViewParameters,
    e:TimelineRelationElement,
    idxFrom:number,
    idxTo:number,
    startCell:WorkPackageTimelineCell,
    endCell:WorkPackageTimelineCell) {

    // If any of the targets are hidden in the table, skip
    if (this.workPackageIdOrder[idxFrom].hidden || this.workPackageIdOrder[idxTo].hidden) {
      return;
    }

    // Skip if relations cannot be drawn between these cells
    if (!startCell.canConnectRelations() || !endCell.canConnectRelations()) {
      return;
    }

    // Get X values
    // const hookLength = endCell.getPaddingLeftForIncomingRelationLines();
    const startX = startCell.getMarginLeftOfRightSide() - startCell.getPaddingRightForOutgoingRelationLines();
    const targetX = endCell.getMarginLeftOfLeftSide() + endCell.getPaddingLeftForIncomingRelationLines();

    // Vertical direction
    const directionY:'toUp' | 'toDown' = idxFrom < idxTo ? 'toDown' : 'toUp';

    // Horizontal direction
    const directionX:'toLeft' | 'beneath' | 'toRight' =
      targetX > startX ? 'toRight' : targetX < startX ? 'toLeft' : 'beneath';

    // start
    if (!startCell) {
      return;
    }

    // Draw the first line next to the bar/milestone element
    const paddingRight = startCell.getPaddingRightForOutgoingRelationLines();
    const startLineWith = endCell.getPaddingLeftForIncomingRelationLines()
      + (paddingRight > 0 ? paddingRight : 0);
    this.container.append(newSegment(vp, e.classNames, idxFrom, 19, startX, startLineWith, 1, 'red'));
    let lastX = startX + startLineWith;
    // lastX += hookLength;

    // Draw vertical line between rows
    const height = Math.abs(idxTo - idxFrom);
    if (directionY === 'toDown') {
      if (directionX === 'toRight' || directionX === 'beneath') {
        this.container.append(newSegment(vp, e.classNames, idxFrom, 19, lastX, 1, height * 41, 'black'));
      } else if (directionX === 'toLeft') {
        this.container.append(newSegment(vp, e.classNames, idxFrom, 19, lastX, 1, (height * 41) - 10, 'black'));
      }
    } else if (directionY === 'toUp') {
      this.container.append(newSegment(vp, e.classNames, idxTo, 30, lastX, 1, (height * 41) - 10, 'black'));
    }

    // Draw end corner to the target
    if (directionX === 'toRight') {
      if (directionY === 'toDown') {
        this.container.append(newSegment(vp, e.classNames, idxTo, 19, lastX, targetX - lastX, 1, 'red'));
      } else if (directionY === 'toUp') {
        this.container.append(newSegment(vp, e.classNames, idxTo, 20, lastX, 1, 10, 'green'));
        this.container.append(newSegment(vp, e.classNames, idxTo, 20, lastX, targetX - lastX, 1, 'lightsalmon'));
      }
    } else if (directionX === 'toLeft') {
      if (directionY === 'toDown') {
        this.container.append(newSegment(vp, e.classNames, idxTo, 0, lastX, 1, 8, 'red'));
        this.container.append(newSegment(vp, e.classNames, idxTo, 8, targetX, lastX - targetX, 1, 'green'));
        this.container.append(newSegment(vp, e.classNames, idxTo, 8, targetX, 1, 11, 'blue'));
      } else if (directionY === 'toUp') {
        this.container.append(newSegment(vp, e.classNames, idxTo, 30, targetX + 1, lastX - targetX, 1, 'red'));
        this.container.append(newSegment(vp, e.classNames, idxTo, 19, targetX + 1, 1, 11, 'blue'));
      }
    }

  }
}

openprojectModule.component('wpTimelineRelations', {
  template: '<div class="wp-table-timeline--relations"></div>',
  controller: WorkPackageTableTimelineRelations,
  require: {
    wpTimeline: '^wpTimelineContainer'
  }
});
